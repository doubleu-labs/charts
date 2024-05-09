
{{- define "dns.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dns.fullname" -}}
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

{{- define "dns.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Name | quote }}
app.kubernetes.io/name: {{ include "dns.name" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{- define "dns.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{ default (include "dns.fullname" .) .Values.serviceAccount.name }}
  {{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}

{{- define "dns.configPorts" -}}
  {{- $ports := dict -}}
  {{- range .Values.servers -}}
    {{- range .zones -}}
      {{- if has (default "" .scheme) (list "dns://") -}}
        {{- $port := (default "53" .port) -}}
        {{- if not (hasKey $ports $port) -}}
          {{- $ports := set $ports $port (dict "istcp" true "isudp" true "proto" "dns") -}}
        {{- end -}}
      {{- end -}}
      {{- if has (default "" .scheme) (list "https://") -}}
        {{- $port := (default "443" .port) -}}
        {{- if not (hasKey $ports $port) -}}
          {{- $ports := set $ports $port (dict "istcp" true "isudp" false "proto" "https") -}}
        {{- end -}}
      {{- end -}}
      {{- if has (default "" .scheme) (list "tls://") -}}
        {{- $port := (default "853" .port) -}}
        {{- if not (hasKey $ports $port) -}}
          {{- $ports := set $ports $port (dict "istcp" true "isudp" false "proto" "tls") -}}
        {{- end -}}
      {{- end -}}
      {{- if .port  -}}
        {{- $port := toString .port -}}
        {{- $innerDict := (dict "istcp" false "isudp" true "proto" "") -}}
        {{- if .scheme -}}
          {{- $schemeList := regexSplit ":" .scheme -1 -}}
          {{- $innerDict := set $innerDict "proto" (index $schemeList 0) -}}
        {{- end -}}
        {{- if .isTCP -}}
          {{- $innerDict := set $innerDict "istcp" true -}}
          {{- $innerDict := set $innerDict "isudp" false -}}
        {{- end -}}
        {{- if not (hasKey $ports $port) -}}
          {{- $ports := set $ports $port $innerDict -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- if not .zones -}}
      {{- if not (hasKey $ports "53") -}}
        {{- $ports := set $ports "53" (dict "istcp" true "isudp" true "proto" "dns") -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $portsList := dict -}}
  {{- range $port, $innerDict := $ports -}}
    {{- $name := (default (printf "%s-generic" $port) (index $innerDict "proto")) -}}
    {{- if index $innerDict "isudp" -}}
      {{- $portsList := set $portsList (printf "udp-%s" $name) (dict "port" ($port | int) "protocol" "UDP") -}}
    {{- end -}}
    {{- if index $innerDict "istcp" -}}
      {{- $portsList := set $portsList (printf "tcp-%s" $name) (dict "port" ($port | int) "protocol" "TCP") -}}
    {{- end -}}
  {{- end -}}
  {{- $portsList | toJson -}}
{{- end -}}


{{- define "dns.servicePorts" -}}
  {{- $portsList := list -}}
  {{- $configPorts := include "dns.configPorts" . | fromJson -}}
  {{- range $name, $innerDict := $configPorts -}}
    {{- $portsList = append $portsList (dict "port" $innerDict.port "protocol" $innerDict.protocol "name" $name) -}}
  {{- end -}}
  {{- range $portsList }}
  - name: {{ .name }}
    port: {{ .port }}
    protocol: {{ .protocol }}
  {{- end }}
{{- end -}}

{{- define "dns.containerPorts" -}}
  {{- $portsList := list -}}
  {{- $configPorts := include "dns.configPorts" . | fromJson -}}
  {{- range $name, $innerDict := $configPorts -}}
    {{- $portsList = append $portsList (dict "port" $innerDict.port "protocol" $innerDict.protocol "name" $name) -}}
  {{- end -}}
  {{- range $portsList }}
        - name: {{ .name }}
          containerPort: {{ .port }}
          protocol: {{ .protocol }}
  {{- end }}
{{- end -}}
