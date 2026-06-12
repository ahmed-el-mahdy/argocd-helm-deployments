{{/*
Common labels
*/}}
{{- define "microservice.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "microservice.selectorLabels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Full image name
*/}}
{{- define "microservice.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end }}
