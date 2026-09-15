{{/*
Expand the name of the chart.
*/}}
{{- define "yieldpoint.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "yieldpoint.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label value.
*/}}
{{- define "yieldpoint.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "yieldpoint.labels" -}}
helm.sh/chart: {{ include "yieldpoint.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: yieldpoint
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Selector labels for a named service.
  Usage: {{ include "yieldpoint.selectorLabels" (dict "name" "auth-service") }}
*/}}
{{- define "yieldpoint.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}

{{/*
Full label set for a named service (common + selector).
  Usage: {{ include "yieldpoint.serviceLabels" (dict "name" "auth-service" "context" $) }}
*/}}
{{- define "yieldpoint.serviceLabels" -}}
{{ include "yieldpoint.labels" .context }}
{{ include "yieldpoint.selectorLabels" (dict "name" .name) }}
{{- end }}

{{/*
Service name from a short key (e.g. "farm" -> "farm-service").
*/}}
{{- define "yieldpoint.serviceName" -}}
{{- printf "%s-service" . }}
{{- end }}

{{/*
Image reference for a service.
  Usage: {{ include "yieldpoint.image" (dict "svcName" "auth-service" "tag" "v1.2.3" "global" .Values.global) }}
*/}}
{{- define "yieldpoint.image" -}}
{{- printf "%s/%s:%s" .global.imageRegistry .svcName (default .global.imageTag .tag) }}
{{- end }}
