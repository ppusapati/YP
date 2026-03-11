package domain

const (
	// HR Appraisal Events
	EventTypeAppraisalCompleted EventType = "hr.appraisal.completed"
	EventTypeAppraisalInitiated EventType = "hr.appraisal.initiated"

	// HR Attendance Events
	EventTypeAttendanceProcessed EventType = "hr.attendance.processed"
	EventTypeAttendanceRecorded  EventType = "hr.attendance.recorded"

	// HR Employee Events
	EventTypeEmployeeActivated EventType = "hr.employee.activated"
	EventTypeEmployeeOnboarded EventType = "hr.employee.onboarded"

	// HR Exit Events
	EventTypeExitCompleted EventType = "hr.exit.completed"
	EventTypeExitInitiated EventType = "hr.exit.initiated"

	// HR Expense Events
	EventTypeExpenseAllocated EventType = "hr.expense.allocated"
	EventTypeExpenseApproved  EventType = "hr.expense.approved"
	EventTypeExpenseSubmitted EventType = "hr.expense.submitted"

	// HR Leave Events
	EventTypeLeaveApproved  EventType = "hr.leave.approved"
	EventTypeLeaveRequested EventType = "hr.leave.requested"

	// HR Recruitment Events
	EventTypeRecruitmentOpened    EventType = "hr.recruitment.opened"
	EventTypeRecruitmentProcessed EventType = "hr.recruitment.processed"

	// HR Salary Events
	EventTypeSalaryRevised EventType = "hr.salary.revised"
	EventTypeSalaryUpdated EventType = "hr.salary.updated"

	// HR Training Events
	EventTypeTrainingCompleted EventType = "hr.training.completed"
	EventTypeTrainingScheduled EventType = "hr.training.scheduled"

	// Finance Events
	EventTypeCostAllocated             EventType = "finance.cost.allocated"
	EventTypeCostAllocationRequired    EventType = "finance.cost.allocation_required"
	EventTypeCostCenterExpenseRecorded EventType = "finance.costcenter.expense_recorded"
	EventTypeJournalRecorded           EventType = "finance.journal.recorded"
	EventTypeManualJournalSubmitted    EventType = "finance.journal.manual_submitted"
)
