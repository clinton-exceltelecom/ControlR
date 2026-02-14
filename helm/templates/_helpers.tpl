{{/*
Expand the name of the chart.
*/}}
{{- define "controlr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "controlr.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "controlr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "controlr.labels" -}}
helm.sh/chart: {{ include "controlr.chart" . }}
{{ include "controlr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "controlr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "controlr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "controlr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "controlr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL fullname
*/}}
{{- define "controlr.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "controlr.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "controlr.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- include "controlr.postgresql.fullname" . }}
{{- else }}
{{- required "A valid .Values.postgresql.externalHost is required when postgresql.enabled is false" .Values.postgresql.externalHost }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "controlr.postgresql.secretName" -}}
{{- if .Values.postgresql.auth.existingSecret }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- include "controlr.postgresql.fullname" . }}
{{- end }}
{{- end }}

{{/*
Aspire fullname
*/}}
{{- define "controlr.aspire.fullname" -}}
{{- printf "%s-aspire" (include "controlr.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Aspire labels
*/}}
{{- define "controlr.aspire.labels" -}}
helm.sh/chart: {{ include "controlr.chart" . }}
{{ include "controlr.aspire.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Aspire selector labels
*/}}
{{- define "controlr.aspire.selectorLabels" -}}
app.kubernetes.io/name: {{ include "controlr.name" . }}-aspire
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: aspire
{{- end }}

{{/*
PostgreSQL labels
*/}}
{{- define "controlr.postgresql.labels" -}}
helm.sh/chart: {{ include "controlr.chart" . }}
{{ include "controlr.postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
PostgreSQL selector labels
*/}}
{{- define "controlr.postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "controlr.name" . }}-postgresql
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: database
{{- end }}
