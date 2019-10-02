{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "node-init.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Fullname of configMap/secret that contains environment vaiables
*/}}
{{- define "node-init.env.fullname" -}}
{{- $root := index . 0 -}}
{{- $postfix := index . 1 -}}
{{- printf "%s-%s-%s" (include "common.fullname" $root) "env" $postfix -}}
{{- end -}}

{{/*
Fullname of configMap/secret that contains files
*/}}
{{- define "node-init.files.fullname" -}}
{{- $root := index . 0 -}}
{{- $postfix := index . 1 -}}
{{- printf "%s-%s-%s" (include "common.fullname" $root) "files" $postfix -}}
{{- end -}}

{{/*
Environment template block for deployable resources
*/}}
{{- define "node-init.env" -}}
{{- $root := . -}}
env:
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
{{- with $root.Values.env }}
{{- range $name, $value := . }}
- name: {{ $name }}
  value: {{ default "" $value | quote }}
{{- end }}
{{- end }}

{{- if or .Values.configMaps $root.Values.secrets }}
envFrom:
{{- range $name, $config := $root.Values.configMaps -}}
{{- if $config.enabled }}
{{- if not ( empty $config.env ) }}
- configMapRef:
    name: {{ include "node-init.env.fullname" (list $root $name) }}
{{- end }}
{{- end }}
{{- end }}
{{- range $name, $secret := $root.Values.secrets -}}
{{- if $secret.enabled }}
{{- if not ( empty $secret.env ) }}
- secretRef:
    name: {{ include "node-init.env.fullname" (list $root $name) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end -}}


{{/*
Volumes template block for deployable resources
*/}}
{{- define "node-init.files.volumes" -}}
{{- $root := . -}}
{{- range $name, $config := $root.Values.configMaps -}}
{{- if $config.enabled }}
{{- if not ( empty $config.files ) }}
- name: config-{{ $name }}-files
  configMap:
    name: {{ include "node-init.files.fullname" (list $root $name) }}
{{- end }}
{{- end }}
{{- end -}}
{{- range $name, $secret := $root.Values.secrets -}}
{{- if $secret.enabled }}
{{- if not ( empty $secret.files ) }}
- name: secret-{{ $name }}-files
  secret:
    secretName: {{ include "node-init.files.fullname" (list $root $name) }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
VolumeMounts template block for deployable resources
*/}}
{{- define "node-init.files.volumeMounts" -}}
{{- range $name, $config := .Values.configMaps -}}
{{- if $config.enabled }}
{{- if not ( empty $config.files ) }}
- mountPath: {{ default (printf "/%s" $name) $config.mountPath }}
  name: config-{{ $name }}-files
{{- end }}
{{- end }}
{{- end -}}
{{- range $name, $secret := .Values.secrets -}}
{{- if $secret.enabled }}
{{- if not ( empty $secret.files ) }}
- mountPath: {{ default (printf "/%s" $name) $secret.mountPath }}
  name: secret-{{ $name }}-files
  readOnly: true
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for RBAC APIs.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if semverCompare "^1.8-0" .Capabilities.KubeVersion.GitVersion -}}
"rbac.authorization.k8s.io/v1"
{{- else -}}
"rbac.authorization.k8s.io/v1beta1"
{{- end -}}
{{- end -}}
