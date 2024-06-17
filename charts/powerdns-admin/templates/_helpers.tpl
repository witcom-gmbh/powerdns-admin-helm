{{/*
Expand the name of the chart.
*/}}
{{- define "powerdns-admin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "powerdns-admin.fullname" -}}
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
{{- define "powerdns-admin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "powerdns-admin.labels" -}}
helm.sh/chart: {{ include "powerdns-admin.chart" . }}
{{ include "powerdns-admin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "powerdns-admin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "powerdns-admin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "powerdns-admin.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "powerdns-admin.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Fail in case database configuration is not complete
*/}}
{{- define "powerdns-admin.database.isConfigured" -}}
{{- $failMessageRaw := `
To configure the databse, you have to either:

  - option 1, set :
    - database.host
    - database.port
    - database.user
    - database.database
    - database.password
  - option 2, provide a secret with the keys (if key is not defined value will be taken from value-specification)
    - database.existingSecret
    - database.existingSecretHostKey
    - database.existingSecretPortKey
	- database.existingSecretUserKey
	- database.existingSecretDatabaseKey
	- database.existingSecretPasswordKey

` -}}
    {{- $failMessage := printf "\n%s" $failMessageRaw | trimSuffix "\n" -}}

	{{- $_ := required $failMessage .Values.database.type -}}

    {{- if (not .Values.database.existingSecret) -}}
        {{- $_ := required $failMessage .Values.database.host -}}
        {{- $_ := required $failMessage .Values.database.port -}}
        {{- $_ := required $failMessage .Values.database.user -}}
        {{- $_ := required $failMessage .Values.database.database -}}
        {{- $_ := required $failMessage .Values.database.password -}}
    {{- end -}}

{{- end -}}
