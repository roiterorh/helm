{{/*
Expand the name of the chart.
*/}}
{{- define "dashy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dashy.fullname" -}}
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
{{- define "dashy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dashy.labels" -}}
helm.sh/chart: {{ include "dashy.chart" . }}
{{ include "dashy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dashy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dashy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dashy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dashy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dashy.configmap" -}}
    pageInfo: 
    {{- range $key, $val := .Values.pageInfo }}
      {{ $key | toYaml}}: {{ required "a valid key is required" $val }}
    {{- end -}}
      
    {{if .Values.appConfig }}
    appConfig:
    {{- if .Values.appConfig.webSearch}}
      webSearch:
      {{- range $key, $val := .Values.appConfig.webSearch }}
        {{ $key }}: {{ required "a valid key is required" $val }}
      {{- end }}{{ end -}}

    {{- if .Values.appConfig.hideComponents}}
      hideComponents:
      {{- range $key, $val := .Values.appConfig.hideComponents }}
        {{ $key }}: {{ required "a valid key is required" $val }}
      {{- end }}{{ end -}}
    {{ range $key, $val := .Values.appConfig }}{{ if and (ne  $key "hideComponents") (ne  $key "webSearch") }}
      {{ $key }}: {{ required "a valid key is required" $val -}}
    {{ end }}{{- end }}
    {{- end }}
    
    {{if .Values.sections }}
    sections: 
      {{- range .Values.sections }}
      - {{- range $key, $val := . -}}
      {{- if or (eq $key "items") (eq $key "widgets") }}
          {{$key}}: 
          {{- range  $val }}
            - {{- range $k, $v := . }}
              {{ $k }}: {{ required "a valid key is required" $v -}}
              {{ end }}
          {{- end }}
      {{- else if eq $key "displayData" }}
          {{$key}}: 
            {{- range $k, $v := . }}
            {{ $k }}: {{ required "a valid key is required" $v -}}
            {{ end }}
      {{- else }}
          {{ $key }}: {{$val}}
      {{- end }}
      {{- end }}
      {{- end }}
    {{- end }}
  
{{- end }}