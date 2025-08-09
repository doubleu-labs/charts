
{{- define "valkey.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "valkey.fullname" -}}
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

{{- define "valkey.labels" -}}
app.kubernetes.io/part-of: valkey
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "valkey.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name (.Chart.Version | replace "+" "_") }}
{{- end -}}

{{- define "valkey.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "valkey.name" . }}
{{- end -}}

{{- define "valkey.objectName" -}}
{{ printf "%s-%s" (include "valkey.fullname" (index . 0)) (index . 1) }}
{{- end -}}

{{- define "valkey.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "valkey.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "valkey.imagePullSecrets" -}}
{{ $pullSecrets := list -}}
{{- range .Values.image.pullSecrets -}}
{{- if kindIs "map" . -}}
{{- $pullSecrets = append $pullSecrets .name -}}
{{- else -}}
{{- $pullSecrets = append $pullSecrets . -}}
{{- end -}}
{{- end -}}
{{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
{{- range $pullSecrets | uniq -}}
  - name: {{ . | quote -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "valkey.image" -}}
{{- $digest := "" -}}
{{- if .Values.image.digest -}}
{{- if hasPrefix "sha256:" .Values.image.digest -}}
{{- $digest = .Values.image.digest -}}
{{- else -}}
{{- $digest = printf "sha256:%s" .Values.image.digest -}}
{{- end -}}
{{- end -}}
{{- printf "%s:%s" .Values.image.repository (coalesce $digest .Values.image.tag .Chart.AppVersion) -}}
{{- end -}}

{{- define "valkey.kubeClientImage" -}}
{{- $digest := "" -}}
{{- if .Values.kubeClientImage.digest -}}
{{- if hasPrefix "sha256:" .Values.kubeClientImage.digest -}}
{{- $digest = .Values.kubeClientImage.digest -}}
{{- else -}}
{{- $digest = printf "sha256:%s" .Values.kubeClientImage.digest -}}
{{- end -}}
{{- end -}}
{{- printf "%s:%s" .Values.kubeClientImage.repository (coalesce $digest .Values.kubeClientImage.tag "latest") -}}
{{- end -}}

{{- define "valkey.serviceName" -}}
{{- $ctx := index . 0}}
{{- $suffix := index . 1 -}}
{{- $override := index . 2 -}}
{{- if $override -}}
{{ $override | quote }}
{{- else -}}
{{ printf "%s-%s" (include "valkey.fullname" $ctx) $suffix }}
{{- end -}}
{{- end -}}

{{- define "valkey.dnsNames" -}}
{{- $list := list -}}
{{- $namespace := index . 1 -}}
{{- $clusterDomain := index . 2 -}}
{{- range $_, $name := (index . 0) -}}
{{- $list = append $list (printf "%s" $name) -}}
{{- $list = append $list (printf "%s.%s" $name $namespace) -}}
{{- $list = append $list (printf "%s.%s.svc" $name $namespace) -}}
{{- $list = append $list (printf "%s.%s.svc.%s" $name $namespace $clusterDomain) -}}
{{- end -}}
{{ $list | toJson }}
{{- end -}}
