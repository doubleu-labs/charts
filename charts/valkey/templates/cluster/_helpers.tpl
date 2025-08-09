
{{- define "valkey.cluster.totalNodes" -}}
{{- $p := (int .Values.cluster.primary.count) -}}
{{- mul $p (int .Values.cluster.replica.count) | add $p -}}
{{- end -}}

{{- define "valkey.cluster.dnsNames" -}}
{{- $names := list -}}
{{- $names = append $names (include "valkey.objectName" (list . "headless")) -}}
{{- $names = append $names (include "valkey.objectName" (list . "r")) -}}
{{ (include "valkey.dnsNames" (list $names .Release.Namespace .Values.service.clusterDomain)) }}
{{- end -}}

{{- define "valkey.cluster.getNodes" -}}
{{- $ctx := index . 0 -}}
{{- $sep := index . 1 -}}
{{- $useProto := index . 2 -}}
{{- $nodes := list -}}
{{- $proto := ternary "valkeys" "valkey" $ctx.Values.tls.certManager.enabled -}}
{{- $fn := include "valkey.fullname" $ctx }}
{{- range $i := until (int (include "valkey.cluster.totalNodes" $ctx)) -}}
{{- $node := (printf "%s-cluster-%d.%s-headless.%s.svc.%s:6379" $fn $i $fn $ctx.Release.Namespace $ctx.Values.service.clusterDomain) -}}
{{- if $useProto -}}
{{- $nodes = append $nodes (printf "%s://%s" $proto $node) -}}
{{- else -}}
{{- $nodes = append $nodes $node }}
{{- end -}}
{{- end -}}
{{- join $sep $nodes -}}
{{- end -}}
