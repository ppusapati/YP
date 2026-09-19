package expression

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

// Evaluator handles evaluation of rule expressions for validation, visibility, and business logic
type Evaluator interface {
	// EvaluateRule evaluates a rule expression against row/field data
	// Supports: field1 == "value" AND field2 > 100 OR field3 IN (1,2,3)
	EvaluateRule(rule string, data map[string]interface{}) (bool, error)

	// ValidateRuleExpression validates rule syntax without executing
	ValidateRuleExpression(rule string) error

	// EvaluateConditionalVisibility checks if field should be visible (hidden_when condition)
	// Returns true if field should be visible (i.e., NOT hidden)
	EvaluateConditionalVisibility(hiddenWhen string, rowData map[string]interface{}) (bool, error)

	// EvaluateConditionalReadonly checks if field should be readonly (readonly_when condition)
	// Returns true if field should be readonly
	EvaluateConditionalReadonly(readonlyWhen string, rowData map[string]interface{}) (bool, error)

	// EvaluateBusinessRule evaluates a business rule validation
	EvaluateBusinessRule(rule string, fieldValue interface{}, rowData map[string]interface{}) error
}

// evaluatorImpl implements Evaluator
type evaluatorImpl struct{}

// NewEvaluator creates a new rule evaluator instance
func NewEvaluator() Evaluator {
	return &evaluatorImpl{}
}

// Operator represents comparison operators used in expressions
type Operator string

const (
	OpEqual         Operator = "=="
	OpNotEqual      Operator = "!="
	OpLessThan      Operator = "<"
	OpLessThanEq    Operator = "<="
	OpGreaterThan   Operator = ">"
	OpGreaterThanEq Operator = ">="
	OpAnd           Operator = "AND"
	OpOr            Operator = "OR"
	OpIn            Operator = "IN"
	OpNotIn         Operator = "NOT IN"
	OpContains      Operator = "CONTAINS"
	OpStartsWith    Operator = "STARTS_WITH"
	OpEndsWith      Operator = "ENDS_WITH"
	OpMatches       Operator = "MATCHES"
)

// EvaluateRule evaluates a rule expression against data
// Supports: field1 == "value" AND field2 > 100 OR field3 IN (1,2,3)
func (e *evaluatorImpl) EvaluateRule(rule string, data map[string]interface{}) (bool, error) {
	rule = strings.TrimSpace(rule)
	if rule == "" {
		return true, nil
	}

	// A sub-expression wrapped in its own parentheses is a rule in miniature:
	// strip them and start again. Without this the group in
	// `a == 1 AND (b > 2 OR c == 3)` reached evaluateCondition whole and was
	// read as a field called "(b".
	if inner, ok := stripOuterParens(rule); ok {
		return e.EvaluateRule(inner, data)
	}

	// Split by OR (lowest precedence)
	orConditions := e.splitByOperator(rule, "OR")
	for _, orPart := range orConditions {
		orResult := true

		// Split by AND (higher precedence)
		andConditions := e.splitByOperator(orPart, "AND")
		for _, andPart := range andConditions {
			andPart = strings.TrimSpace(andPart)

			var (
				result bool
				err    error
			)
			if inner, ok := stripOuterParens(andPart); ok {
				result, err = e.EvaluateRule(inner, data)
			} else {
				result, err = e.evaluateCondition(andPart, data)
			}
			if err != nil {
				return false, err
			}

			orResult = orResult && result
			if !orResult {
				break
			}
		}

		if orResult {
			return true, nil
		}
	}

	return false, nil
}

// evaluateCondition evaluates a single condition like "field1 == value"
func (e *evaluatorImpl) evaluateCondition(condition string, data map[string]interface{}) (bool, error) {
	condition = strings.TrimSpace(condition)

	op, start, end, ok := findOperator(condition)
	if !ok {
		return false, fmt.Errorf("invalid condition: %s", condition)
	}

	fieldID := strings.TrimSpace(condition[:start])
	rhs := strings.TrimSpace(condition[end:])

	if fieldID == "" {
		return false, fmt.Errorf("invalid condition: %s", condition)
	}

	// Get field value from data
	fieldValue, exists := data[fieldID]
	if !exists {
		return false, fmt.Errorf("field not found: %s", fieldID)
	}

	// The right-hand side may name another field. `discount < subtotal` is a
	// grid rule someone would reasonably write, and it used to fail with
	// "invalid numeric value: subtotal" — the literal name parsed as a number.
	//
	// Only an unquoted bare identifier that the row actually carries is read
	// this way. `status == "approved"` stays a literal because it is quoted,
	// and `status == approved` stays a literal because no field is called
	// approved; a rule cannot start meaning something else because a column
	// was added elsewhere with a value's name.
	if op != OpIn && op != OpNotIn && isBareIdentifier(rhs) {
		if referenced, found := data[rhs]; found {
			return e.compareValues(fieldValue, op, fmt.Sprintf("%v", referenced))
		}
	}

	return e.compareValues(fieldValue, op, rhs)
}

// identifierChar reports whether c can appear inside a field name or a word
// operator, which is what makes a word-boundary test possible.
func identifierChar(c byte) bool {
	return c == '_' ||
		(c >= 'a' && c <= 'z') ||
		(c >= 'A' && c <= 'Z') ||
		(c >= '0' && c <= '9')
}

var bareIdentifierRe = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_.]*$`)

func isBareIdentifier(s string) bool { return bareIdentifierRe.MatchString(s) }

// wordOperators must be matched on word boundaries; symbolOperators must not.
//
// Both lists are ordered longest-first so that a tie at the same position
// resolves to the longer operator: `>=` rather than `>`, `NOT IN` rather than
// the `IN` inside it.
var (
	wordOperators = []Operator{
		OpStartsWith, OpEndsWith, OpContains, OpMatches, OpNotIn, OpIn,
	}
	symbolOperators = []Operator{
		OpGreaterThanEq, OpLessThanEq, OpNotEqual, OpEqual, OpGreaterThan, OpLessThan,
	}
)

// findOperator locates the comparison operator in a single condition.
//
// It used to be `strings.SplitN` against each operator in turn, which split on
// any substring anywhere. Two consequences, both of which the tests caught:
// `description CONTAINS invoice` split on the `IN` inside `CONTAINS` and looked
// for a field called "description CONTA", and `status NOT IN (a,b)` split on
// the `IN` inside `NOT IN` and looked for "status NOT". A third was waiting:
// any field whose name contains a word operator — `origin`, `printed`,
// `maintenance` — would have split in the middle of its own name.
//
// So word operators match only between non-identifier characters, symbol
// operators match anywhere, and neither matches inside a quoted string or
// inside parentheses. The earliest match wins, and the longest at that
// position.
func findOperator(condition string) (Operator, int, int, bool) {
	var (
		best      Operator
		bestStart = -1
		bestEnd   int
	)

	consider := func(op Operator, start int) {
		end := start + len(op)
		if bestStart == -1 || start < bestStart || (start == bestStart && end > bestEnd) {
			best, bestStart, bestEnd = op, start, end
		}
	}

	var (
		depth int
		quote byte
	)
	for i := 0; i < len(condition); i++ {
		c := condition[i]

		if quote != 0 {
			if c == quote {
				quote = 0
			}
			continue
		}
		switch c {
		case '"', '\'':
			quote = c
			continue
		case '(':
			depth++
			continue
		case ')':
			depth--
			continue
		}
		if depth != 0 {
			continue
		}

		for _, op := range symbolOperators {
			if strings.HasPrefix(condition[i:], string(op)) {
				consider(op, i)
				break
			}
		}
		for _, op := range wordOperators {
			if !strings.HasPrefix(condition[i:], string(op)) {
				continue
			}
			if i > 0 && identifierChar(condition[i-1]) {
				continue
			}
			after := i + len(op)
			if after < len(condition) && identifierChar(condition[after]) {
				continue
			}
			consider(op, i)
			break
		}
	}

	if bestStart == -1 {
		return "", 0, 0, false
	}
	return best, bestStart, bestEnd, true
}

// stripOuterParens removes one layer of parentheses that wraps the whole
// expression, and reports whether it did.
//
// The depth walk matters: `(a) AND (b)` opens and closes twice, and naively
// trimming the first and last byte would leave `a) AND (b`.
func stripOuterParens(s string) (string, bool) {
	s = strings.TrimSpace(s)
	if len(s) < 2 || s[0] != '(' || s[len(s)-1] != ')' {
		return s, false
	}

	depth := 0
	var quote byte
	for i := 0; i < len(s); i++ {
		c := s[i]
		if quote != 0 {
			if c == quote {
				quote = 0
			}
			continue
		}
		switch c {
		case '"', '\'':
			quote = c
		case '(':
			depth++
		case ')':
			depth--
			if depth == 0 && i != len(s)-1 {
				return s, false
			}
		}
	}
	if depth != 0 {
		return s, false
	}
	return strings.TrimSpace(s[1 : len(s)-1]), true
}

// compareValues performs the actual comparison
func (e *evaluatorImpl) compareValues(fieldValue interface{}, op Operator, ruleValue interface{}) (bool, error) {
	ruleStr := fmt.Sprintf("%v", ruleValue)
	ruleStr = strings.Trim(ruleStr, "\"'")

	switch op {
	case OpEqual:
		return e.equals(fieldValue, ruleStr)

	case OpNotEqual:
		result, err := e.equals(fieldValue, ruleStr)
		return !result, err

	case OpLessThan:
		return e.lessThan(fieldValue, ruleStr)

	// The three derived comparisons propagate the error rather than discarding
	// it. `!lt` on a comparison that could not be made returns true, so a rule
	// like `name >= 5` used to report that a string was greater than a number
	// instead of saying it could not tell.
	case OpLessThanEq:
		lt, err := e.lessThan(fieldValue, ruleStr)
		if err != nil {
			return false, err
		}
		eq, err := e.equals(fieldValue, ruleStr)
		if err != nil {
			return false, err
		}
		return eq || lt, nil

	case OpGreaterThan:
		lt, err := e.lessThan(fieldValue, ruleStr)
		if err != nil {
			return false, err
		}
		eq, err := e.equals(fieldValue, ruleStr)
		if err != nil {
			return false, err
		}
		return !lt && !eq, nil

	case OpGreaterThanEq:
		lt, err := e.lessThan(fieldValue, ruleStr)
		if err != nil {
			return false, err
		}
		return !lt, nil

	case OpIn:
		return e.in(fieldValue, ruleStr)

	case OpNotIn:
		result, err := e.in(fieldValue, ruleStr)
		return !result, err

	case OpContains:
		return e.contains(fieldValue, ruleStr)

	case OpStartsWith:
		return e.startsWith(fieldValue, ruleStr)

	case OpEndsWith:
		return e.endsWith(fieldValue, ruleStr)

	case OpMatches:
		return e.matches(fieldValue, ruleStr)

	default:
		return false, fmt.Errorf("unknown operator: %s", op)
	}
}

// equals performs equality comparison with case-insensitive string comparison
//
// Numbers are compared numerically when both sides are numeric, so that a row
// carrying 1000.0 satisfies `amount == 1000`. Comparing their renderings would
// make that false, which is a surprise a rule author has no way to see.
func (e *evaluatorImpl) equals(fieldValue interface{}, ruleValue string) (bool, error) {
	if fNum, ferr := e.toFloat(fieldValue); ferr == nil {
		if rNum, rerr := strconv.ParseFloat(strings.TrimSpace(ruleValue), 64); rerr == nil {
			return fNum == rNum, nil
		}
	}

	fStr := fmt.Sprintf("%v", fieldValue)
	return strings.EqualFold(strings.TrimSpace(fStr), ruleValue), nil
}

// lessThan performs numeric less than comparison
func (e *evaluatorImpl) lessThan(fieldValue interface{}, ruleValue string) (bool, error) {
	fNum, err := e.toFloat(fieldValue)
	if err != nil {
		return false, err
	}

	rNum, err := strconv.ParseFloat(ruleValue, 64)
	if err != nil {
		return false, fmt.Errorf("invalid numeric value: %s", ruleValue)
	}

	return fNum < rNum, nil
}

// in checks whether the value appears in a parenthesised, comma-separated list.
//
// The list arrives as it was written — `(US,UK,CA)` or `("active", "pending")`
// — so the parentheses come off here and the quotes come off each element
// rather than off the list as a whole. Trimming quotes from the whole string,
// which is what compareValues does for every other operator, leaves `("active"`
// as the first member and matches nothing.
func (e *evaluatorImpl) in(fieldValue interface{}, ruleValue string) (bool, error) {
	list := strings.TrimSpace(ruleValue)
	if strings.HasPrefix(list, "(") && strings.HasSuffix(list, ")") {
		list = list[1 : len(list)-1]
	}

	fStr := strings.TrimSpace(fmt.Sprintf("%v", fieldValue))

	for _, v := range strings.Split(list, ",") {
		v = strings.Trim(strings.TrimSpace(v), `"'`)
		if strings.EqualFold(fStr, v) {
			return true, nil
		}
	}
	return false, nil
}

// contains checks if string contains substring
func (e *evaluatorImpl) contains(fieldValue interface{}, ruleValue string) (bool, error) {
	fStr := fmt.Sprintf("%v", fieldValue)
	return strings.Contains(fStr, ruleValue), nil
}

// startsWith checks if string starts with prefix
func (e *evaluatorImpl) startsWith(fieldValue interface{}, ruleValue string) (bool, error) {
	fStr := fmt.Sprintf("%v", fieldValue)
	return strings.HasPrefix(fStr, ruleValue), nil
}

// endsWith checks if string ends with suffix
func (e *evaluatorImpl) endsWith(fieldValue interface{}, ruleValue string) (bool, error) {
	fStr := fmt.Sprintf("%v", fieldValue)
	return strings.HasSuffix(fStr, ruleValue), nil
}

// matches checks if string matches regex pattern
func (e *evaluatorImpl) matches(fieldValue interface{}, ruleValue string) (bool, error) {
	fStr := fmt.Sprintf("%v", fieldValue)
	matched, err := regexp.MatchString(ruleValue, fStr)
	if err != nil {
		return false, fmt.Errorf("invalid regex pattern: %w", err)
	}
	return matched, nil
}

// toFloat converts value to float64
func (e *evaluatorImpl) toFloat(value interface{}) (float64, error) {
	switch v := value.(type) {
	case float64:
		return v, nil
	case float32:
		return float64(v), nil
	case int:
		return float64(v), nil
	case int64:
		return float64(v), nil
	case int32:
		return float64(v), nil
	case string:
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return 0, fmt.Errorf("cannot convert to number: %v", value)
		}
		return f, nil
	default:
		return 0, fmt.Errorf("cannot convert to number: %v", value)
	}
}

// splitByOperator splits a rule on AND or OR, respecting parentheses, quoted
// strings and word boundaries.
//
// The boundary test is not a refinement. Matching "OR" as a bare substring
// splits `order_total > 5` into nothing and `der_total > 5`, and "AND" splits
// `brand == "x"` in the middle of the field name — so any rule naming a column
// that happens to contain those two letters evaluated against a field that does
// not exist. The quote test is the same defect one step along: a rule comparing
// against the literal "PENDING OR APPROVED" would have been split inside its
// own string.
func (e *evaluatorImpl) splitByOperator(s string, operator string) []string {
	var parts []string
	var current strings.Builder
	var quote byte
	parenDepth := 0

	for i := 0; i < len(s); i++ {
		ch := s[i]

		if quote != 0 {
			current.WriteByte(ch)
			if ch == quote {
				quote = 0
			}
			continue
		}

		switch {
		case ch == '"' || ch == '\'':
			quote = ch
			current.WriteByte(ch)
		case ch == '(':
			parenDepth++
			current.WriteByte(ch)
		case ch == ')':
			parenDepth--
			current.WriteByte(ch)
		case parenDepth == 0 && matchesWordAt(s, i, operator):
			if part := strings.TrimSpace(current.String()); part != "" {
				parts = append(parts, part)
			}
			current.Reset()
			i += len(operator) - 1
		default:
			current.WriteByte(ch)
		}
	}

	if part := strings.TrimSpace(current.String()); part != "" {
		parts = append(parts, part)
	}

	return parts
}

// matchesWordAt reports whether word occurs at s[i] bounded by non-identifier
// characters on both sides.
func matchesWordAt(s string, i int, word string) bool {
	if i+len(word) > len(s) || s[i:i+len(word)] != word {
		return false
	}
	if i > 0 && identifierChar(s[i-1]) {
		return false
	}
	if after := i + len(word); after < len(s) && identifierChar(s[after]) {
		return false
	}
	return true
}

// ValidateRuleExpression validates rule syntax without executing
func (e *evaluatorImpl) ValidateRuleExpression(rule string) error {
	if rule == "" {
		return nil
	}

	// Check for balanced parentheses
	parenCount := 0
	for _, ch := range rule {
		if ch == '(' {
			parenCount++
		} else if ch == ')' {
			parenCount--
		}
		if parenCount < 0 {
			return fmt.Errorf("unbalanced parentheses in rule: %s", rule)
		}
	}
	if parenCount != 0 {
		return fmt.Errorf("unbalanced parentheses in rule: %s", rule)
	}

	// Basic validation — should contain at least one condition.
	//
	// Asked of the same matcher the evaluator uses, not of strings.Contains:
	// a rule reading `printing_status` contains "IN" as a substring and would
	// have validated as though it held an operator, then failed at evaluation
	// time against data the author could no longer see.
	if _, _, _, ok := findOperator(rule); !ok {
		return fmt.Errorf("rule must contain at least one operator: %s", rule)
	}

	return nil
}

// EvaluateConditionalVisibility checks if field should be visible (hidden_when condition)
// Returns true if field should be visible (i.e., NOT hidden)
func (e *evaluatorImpl) EvaluateConditionalVisibility(hiddenWhen string, rowData map[string]interface{}) (bool, error) {
	if hiddenWhen == "" {
		return true, nil // visible by default
	}

	hidden, err := e.EvaluateRule(hiddenWhen, rowData)
	if err != nil {
		return true, fmt.Errorf("failed to evaluate hidden_when: %w", err)
	}

	return !hidden, nil // return opposite (visible = not hidden)
}

// EvaluateConditionalReadonly checks if field should be readonly (readonly_when condition)
// Returns true if field should be readonly
func (e *evaluatorImpl) EvaluateConditionalReadonly(readonlyWhen string, rowData map[string]interface{}) (bool, error) {
	if readonlyWhen == "" {
		return false, nil // not readonly by default
	}

	readonly, err := e.EvaluateRule(readonlyWhen, rowData)
	if err != nil {
		return false, fmt.Errorf("failed to evaluate readonly_when: %w", err)
	}

	return readonly, nil
}

// EvaluateBusinessRule evaluates a business rule validation
func (e *evaluatorImpl) EvaluateBusinessRule(rule string, fieldValue interface{}, rowData map[string]interface{}) error {
	if rule == "" {
		return nil
	}

	// Create data context with current field value
	context := make(map[string]interface{})
	for k, v := range rowData {
		context[k] = v
	}
	context["_value"] = fieldValue

	result, err := e.EvaluateRule(rule, context)
	if err != nil {
		return fmt.Errorf("failed to evaluate business rule: %w", err)
	}

	if !result {
		return fmt.Errorf("validation failed: business rule not satisfied")
	}

	return nil
}
