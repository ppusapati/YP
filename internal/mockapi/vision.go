package mockapi

import (
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"sort"
	"strings"
)

// PlantNet, Google Vision and "custom" vision stand-ins.
//
// The diagnosis returned is a function of the image bytes, so the same
// photograph always comes back with the same verdict. That is what makes the
// mock useful for testing: a fixture image can be checked in and asserted
// against, and a UI can be developed against a stable answer rather than one
// that changes on every reload.
//
// The catalogue below is real crops and real diseases, for the same reason the
// weather numbers are plausible — "Lorem Ipsum Blight" at 99% confidence never
// reveals that a label overflows its container, that a severity string is not
// handled, or that the treatment list renders badly at four items.

type detection struct {
	Label           string   `json:"label"`
	ScientificName  string   `json:"scientific_name,omitempty"`
	Confidence      float64  `json:"confidence"`
	Category        string   `json:"category,omitempty"`
	Description     string   `json:"description,omitempty"`
	Severity        string   `json:"severity,omitempty"`
	Recommendations []string `json:"recommendations,omitempty"`
	// family is PlantNet's taxonomy field, which the client reads as category.
	family string
}

// catalogue holds plausible answers per task.
var catalogue = map[string][]detection{
	"disease": {
		{
			Label: "Tomato Late Blight", ScientificName: "Phytophthora infestans",
			Category: "Oomycete", Severity: "high", family: "Peronosporaceae",
			Description: "Water-soaked lesions on leaves with white sporulation on the underside, spreading rapidly in cool wet weather.",
			Recommendations: []string{
				"Remove and destroy affected foliage; do not compost it",
				"Apply a protectant fungicide such as mancozeb before the next rain",
				"Improve airflow by widening plant spacing at the next sowing",
			},
		},
		{
			Label: "Rice Blast", ScientificName: "Magnaporthe oryzae",
			Category: "Fungus", Severity: "high", family: "Magnaporthaceae",
			Description: "Diamond-shaped lesions with grey centres on leaves; neck infection can cause complete panicle loss.",
			Recommendations: []string{
				"Avoid excess nitrogen, which makes the crop more susceptible",
				"Apply tricyclazole at boot leaf stage where pressure is high",
				"Drain the field intermittently rather than holding standing water",
			},
		},
		{
			Label: "Wheat Leaf Rust", ScientificName: "Puccinia triticina",
			Category: "Fungus", Severity: "moderate", family: "Pucciniaceae",
			Description: "Small orange-brown pustules scattered on the upper leaf surface, most damaging when it reaches the flag leaf.",
			Recommendations: []string{
				"Scout the flag leaf weekly from heading onward",
				"Apply a triazole fungicide if pustules reach the flag leaf",
				"Prefer a resistant variety in the next season",
			},
		},
		{
			Label: "Cotton Bacterial Blight", ScientificName: "Xanthomonas citri pv. malvacearum",
			Category: "Bacterium", Severity: "moderate", family: "Xanthomonadaceae",
			Description: "Angular water-soaked spots bounded by leaf veins, later turning brown and shedding.",
			Recommendations: []string{
				"Treat seed with an approved bactericide before sowing",
				"Avoid working the field while the canopy is wet",
				"Remove crop residue after harvest to reduce carry-over",
			},
		},
		{
			Label: "Healthy", Category: "None", Severity: "none", family: "",
			Description: "No disease symptoms detected in the submitted image.",
		},
	},
	"pest": {
		{
			Label: "Fall Armyworm", ScientificName: "Spodoptera frugiperda",
			Category: "Lepidoptera", Severity: "high", family: "Noctuidae",
			Description: "Ragged feeding windows in the whorl with moist sawdust-like frass; larvae feed at night.",
			Recommendations: []string{
				"Scout 20 plants at five points and count infested whorls",
				"Apply whorl-directed spray only above the 5% damage threshold",
				"Release Trichogramma cards where an early infestation is caught",
			},
		},
		{
			Label: "Pink Bollworm", ScientificName: "Pectinophora gossypiella",
			Category: "Lepidoptera", Severity: "high", family: "Gelechiidae",
			Description: "Rosetted flowers and exit holes in bolls; larvae feed on developing seed inside the boll.",
			Recommendations: []string{
				"Install pheromone traps at 5 per hectare and record weekly catch",
				"Destroy rosetted flowers as they appear",
				"Observe the recommended terminal date for the crop",
			},
		},
		{
			Label: "Brown Planthopper", ScientificName: "Nilaparvata lugens",
			Category: "Hemiptera", Severity: "moderate", family: "Delphacidae",
			Description: "Circular patches of dried plants — hopperburn — spreading outward from the point of infestation.",
			Recommendations: []string{
				"Part the canopy and inspect the base of the plant, not the leaves",
				"Drain the field for three to four days",
				"Avoid pyrethroids, which kill the natural predators and worsen it",
			},
		},
		{
			Label: "Aphid Infestation", ScientificName: "Aphis gossypii",
			Category: "Hemiptera", Severity: "low", family: "Aphididae",
			Description: "Colonies on the underside of young leaves with honeydew and sooty mould below.",
			Recommendations: []string{
				"Check for ladybird beetles before deciding to spray",
				"A strong water spray is often enough at low density",
				"Use a selective aphicide only above threshold",
			},
		},
		{
			Label: "No Pest Detected", Category: "None", Severity: "none", family: "",
			Description: "No pest damage detected in the submitted image.",
		},
	},
	"nutrient_deficiency": {
		{
			Label: "Nitrogen Deficiency", Category: "Macronutrient", Severity: "moderate", family: "",
			Description: "Uniform pale green to yellow on the older leaves first, since nitrogen moves to the new growth.",
			Recommendations: []string{
				"Apply a top dressing of urea at 40 kg N per hectare",
				"Split the remaining dose rather than applying it all at once",
				"Confirm against a soil test before increasing the season total",
			},
		},
		{
			Label: "Potassium Deficiency", Category: "Macronutrient", Severity: "moderate", family: "",
			Description: "Scorching and browning along the leaf margins of older leaves, progressing inward.",
			Recommendations: []string{
				"Apply muriate of potash at 30 kg K2O per hectare",
				"A foliar spray of 1% KCl gives a faster response on a standing crop",
			},
		},
		{
			Label: "Zinc Deficiency", Category: "Micronutrient", Severity: "low", family: "",
			Description: "Interveinal chlorosis on young leaves with shortened internodes, common on alkaline soils.",
			Recommendations: []string{
				"Spray 0.5% zinc sulphate with lime at two-week intervals",
				"Zinc availability falls as pH rises; check soil pH alongside",
			},
		},
		{
			Label: "Iron Deficiency", Category: "Micronutrient", Severity: "low", family: "",
			Description: "Sharp interveinal chlorosis on the youngest leaves while the veins stay green.",
			Recommendations: []string{
				"Apply chelated iron as a foliar spray; soil-applied iron is often locked up",
				"Check for waterlogging, which restricts iron uptake",
			},
		},
		{
			Label: "No Deficiency", Category: "None", Severity: "none", family: "",
			Description: "Nutrient status appears adequate in the submitted image.",
		},
	},
	"classification": {
		{Label: "Tomato", ScientificName: "Solanum lycopersicum", Category: "Solanaceae", family: "Solanaceae"},
		{Label: "Rice", ScientificName: "Oryza sativa", Category: "Poaceae", family: "Poaceae"},
		{Label: "Wheat", ScientificName: "Triticum aestivum", Category: "Poaceae", family: "Poaceae"},
		{Label: "Cotton", ScientificName: "Gossypium hirsutum", Category: "Malvaceae", family: "Malvaceae"},
		{Label: "Chickpea", ScientificName: "Cicer arietinum", Category: "Fabaceae", family: "Fabaceae"},
		{Label: "Sugarcane", ScientificName: "Saccharum officinarum", Category: "Poaceae", family: "Poaceae"},
		{Label: "Maize", ScientificName: "Zea mays", Category: "Poaceae", family: "Poaceae"},
	},
}

// fingerprint reduces an image to a short stable key. Hashing the whole body
// rather than its length means two different images of the same size get
// different diagnoses, which is the entire point.
func fingerprint(image []byte) string {
	// The bytes go in as a string key; the hash inside unit() does the work.
	return string(image)
}

// diagnose picks a deterministic ranked list for an image and task.
//
// The chosen entry leads, and the rest of the catalogue follows at lower
// confidence — because a UI that only ever sees one result never gets tested
// for how it renders the second and third.
func diagnose(image []byte, task string, limit int) []detection {
	entries, ok := catalogue[task]
	if !ok {
		entries = catalogue["disease"]
	}
	key := fingerprint(image) + "|" + task

	lead := int(unit(key+"|pick") * float64(len(entries)))
	if lead >= len(entries) {
		lead = len(entries) - 1
	}

	out := make([]detection, 0, len(entries))
	for i, e := range entries {
		c := e
		if i == lead {
			// A confident but not absurd lead. Nothing real returns 1.0, and a
			// mock that does hides every "high confidence" branch in the UI.
			c.Confidence = round2(0.72 + 0.25*unit(key+"|lead"))
		} else {
			c.Confidence = round2(0.02 + 0.34*unit(key+"|alt"+e.Label))
		}
		out = append(out, c)
	}

	sort.SliceStable(out, func(i, j int) bool { return out[i].Confidence > out[j].Confidence })
	if limit > 0 && len(out) > limit {
		out = out[:limit]
	}
	return out
}

type visionHandlers struct {
	faults *faultStore
}

// ── PlantNet ────────────────────────────────────────────────────────────────

// handlePlantNet serves POST /v2/identify/all, which takes multipart form data
// with the image under "images".
func (h *visionHandlers) handlePlantNet(w http.ResponseWriter, r *http.Request) {
	if h.faults.apply(w, "plantnet") {
		return
	}
	if r.URL.Query().Get("api-key") == "" {
		writeJSON(w, http.StatusUnauthorized, map[string]any{
			"statusCode": 401, "error": "Unauthorized", "message": "Invalid or missing API key",
		})
		return
	}

	image, err := multipartImage(r, "images")
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"statusCode": 400, "error": "Bad Request", "message": err.Error(),
		})
		return
	}

	// PlantNet is a species identifier, so it answers the classification
	// question regardless of what the caller is ultimately trying to find out.
	results := make([]map[string]any, 0, 10)
	for _, d := range diagnose(image, "classification", 10) {
		species := map[string]any{
			"scientificNameWithoutAuthor": d.ScientificName,
			"scientificNameAuthorship":    "L.",
			"scientificName":              d.ScientificName + " L.",
			"genus": map[string]any{
				"scientificNameWithoutAuthor": firstWord(d.ScientificName),
			},
			"family": map[string]any{
				"scientificNameWithoutAuthor": d.family,
			},
			"commonNames": []string{d.Label},
		}
		results = append(results, map[string]any{
			"score": d.Confidence, "species": species, "gbif": map[string]any{"id": "0"},
		})
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"query": map[string]any{
			"project": "all", "images": []string{"image.jpg"},
			"organs": []string{"leaf"}, "includeRelatedImages": false,
		},
		"language": "en", "preferedReferential": "k-world-flora",
		"bestMatch":                       results[0]["species"].(map[string]any)["scientificNameWithoutAuthor"],
		"results":                         results,
		"version":                         "2024-06-20 (7.3)",
		"remainingIdentificationRequests": 499,
	})
}

// ── Google Cloud Vision ─────────────────────────────────────────────────────

type annotateRequest struct {
	Requests []struct {
		Image struct {
			Content string `json:"content"`
		} `json:"image"`
		Features []struct {
			Type       string `json:"type"`
			MaxResults int    `json:"maxResults"`
		} `json:"features"`
	} `json:"requests"`
}

// handleGoogleVision serves POST /v1/images:annotate.
func (h *visionHandlers) handleGoogleVision(w http.ResponseWriter, r *http.Request) {
	if h.faults.apply(w, "vision") {
		return
	}
	if r.URL.Query().Get("key") == "" {
		writeJSON(w, http.StatusUnauthorized, map[string]any{
			"error": map[string]any{
				"code": 401, "status": "UNAUTHENTICATED",
				"message": "Request is missing required authentication credential.",
			},
		})
		return
	}

	var req annotateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || len(req.Requests) == 0 {
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"error": map[string]any{"code": 400, "status": "INVALID_ARGUMENT", "message": "Invalid request"},
		})
		return
	}

	image, _ := base64.StdEncoding.DecodeString(req.Requests[0].Image.Content)
	limit := 15
	if len(req.Requests[0].Features) > 0 && req.Requests[0].Features[0].MaxResults > 0 {
		limit = req.Requests[0].Features[0].MaxResults
	}

	// Cloud Vision returns generic labels, not agronomic diagnoses. Pretending
	// otherwise would make the gateway's provider-specific handling look
	// interchangeable when it is not.
	labels := make([]map[string]any, 0, limit)
	for _, d := range diagnose(image, "classification", limit) {
		labels = append(labels, map[string]any{
			"mid":         "/m/0" + firstWord(strings.ToLower(d.Label)),
			"description": d.Label, "score": d.Confidence, "topicality": d.Confidence,
		})
	}
	for _, generic := range []string{"Plant", "Leaf", "Terrestrial plant", "Agriculture"} {
		if len(labels) >= limit {
			break
		}
		labels = append(labels, map[string]any{
			"mid":         "/m/0" + strings.ToLower(firstWord(generic)),
			"description": generic,
			"score":       round2(0.60 + 0.3*unit(fingerprint(image)+generic)),
			"topicality":  0.8,
		})
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"responses": []map[string]any{{"labelAnnotations": labels}},
	})
}

// ── Custom provider ─────────────────────────────────────────────────────────

type analyzeRequest struct {
	Image  string `json:"image"`
	Task   string `json:"task"`
	Format string `json:"format"`
}

// handleCustomAnalyze serves POST /analyze, the gateway's own provider shape.
//
// This is the richest of the three — it is the only one that carries severity
// and treatment recommendations through to the response — so it is the one to
// point at while developing the diagnosis UI.
func (h *visionHandlers) handleCustomAnalyze(w http.ResponseWriter, r *http.Request) {
	if h.faults.apply(w, "custom") {
		return
	}
	if auth := r.Header.Get("Authorization"); !strings.HasPrefix(auth, "Bearer ") {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "missing bearer token"})
		return
	}

	var req analyzeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
		return
	}
	image, err := base64.StdEncoding.DecodeString(req.Image)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "image is not valid base64"})
		return
	}

	task := req.Task
	if task == "" {
		task = "disease"
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"task":       task,
		"model":      "mockserver-catalogue/1",
		"results":    diagnose(image, task, 5),
		"image_size": len(image),
	})
}

// ── helpers ─────────────────────────────────────────────────────────────────

// multipartImage pulls one uploaded file out of a multipart body.
func multipartImage(r *http.Request, field string) ([]byte, error) {
	// 32 MB is the ceiling held in memory before spilling to disk; the
	// diagnosis path caps uploads well below this.
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		return nil, err
	}
	file, _, err := r.FormFile(field)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	return io.ReadAll(file)
}

func firstWord(s string) string {
	if i := strings.IndexByte(s, ' '); i > 0 {
		return s[:i]
	}
	return s
}
