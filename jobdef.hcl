{
  "Stop": false,
  "Region": "global",
  "Namespace": "default",
  "ID": "quiet-sky-baemgz-storage-clone",
  "ParentID": "",
  "Name": "quiet-sky-baemgz-storage-clone",
  "Type": "batch",
  "Priority": 50,
  "AllAtOnce": false,
  "Datacenters": [
    "us-west-aws"
  ],
  "NodePool": "us-west-aws",
  "Constraints": null,
  "Affinities": null,
  "Spreads": null,
  "TaskGroups": [
    {
      "Name": "quiet-sky-baemgz-storage-clone",
      "Count": 1,
      "Update": null,
      "Migrate": null,
      "Constraints": null,
      "Scaling": null,
      "RestartPolicy": {
        "Attempts": 3,
        "Interval": 86400000000000,
        "Delay": 15000000000,
        "Mode": "fail",
        "RenderTemplates": false
      },
      "Disconnect": null,
      "Tasks": [
        {
          "Name": "quiet-sky-baemgz-events-clone",
          "Driver": "raw_exec",
          "User": "",
          "Config": {
            "args": [
              "-c",
              "curl -X PUT -H 'Content-Type: application/json' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6IlE3dm5TYTNIRHQzM3RHdHgiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3p2Y3BuYWh0b2pmYmJldG5sc2hqLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJhZjg0NDBhOC1kNTk0LTQ3ODgtODJhMi03YjYzNDM4ZWE3NmQiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzQ3MDQ0NDkxLCJpYXQiOjE3NDcwNDA4OTEsImVtYWlsIjoib3duZXJAZ3VlcGFyZC5ydW4iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJvbmJvYXJkZWQiOnRydWUsInByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnsiZW1haWxfdmVyaWZpZWQiOnRydWV9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNzQ2NjExMDM2fV0sInNlc3Npb25faWQiOiI4NmIxMTY5Yy0wNjg0LTRhYTctOTJiMy03ZGE1ZTJmZThiNzkiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.mFPYah5tw5vNUZMCA5xBnUwUV9c_Ae8G4v5g4o3pNNg' -d '{\"object_id\":\"5f67dbb9-b7e1-4958-a95f-8234aed67431\",\"object_type\":\"clone\",\"event_type\":\"CREATED\"}' https://api.dev.guepard.run/deploy/8bb0f962-842d-4c11-a048-1ed1ea6ad90c/events"
            ],
            "command": "/bin/sh"
          },
          "Env": null,
          "Services": null,
          "Vault": null,
          "Consul": null,
          "Templates": null,
          "Constraints": [
            {
              "LTarget": "${meta.storage}",
              "RTarget": "true",
              "Operand": "="
            },
            {
              "LTarget": "${meta.datacenter}",
              "RTarget": "us-west-aws",
              "Operand": "="
            }
          ],
          "Affinities": null,
          "Resources": {
            "CPU": 10,
            "Cores": 0,
            "MemoryMB": 10,
            "MemoryMaxMB": 0,
            "DiskMB": 0,
            "IOPS": 0,
            "Networks": null,
            "Devices": null,
            "NUMA": null,
            "SecretsMB": 0
          },
          "RestartPolicy": {
            "Attempts": 3,
            "Interval": 86400000000000,
            "Delay": 15000000000,
            "Mode": "fail",
            "RenderTemplates": false
          },
          "DispatchPayload": null,
          "Lifecycle": {
            "Hook": "poststop",
            "Sidecar": false
          },
          "Meta": {
            "customer_id": "af8440a8-d594-4788-82a2-7b63438ea76d",
            "deployment_id": "8bb0f962-842d-4c11-a048-1ed1ea6ad90c",
            "clone_id": "5f67dbb9-b7e1-4958-a95f-8234aed67431"
          },
          "KillTimeout": 5000000000,
          "LogConfig": {
            "MaxFiles": 10,
            "MaxFileSizeMB": 10,
            "Disabled": false
          },
          "Artifacts": null,
          "Leader": false,
          "ShutdownDelay": 0,
          "VolumeMounts": null,
          "ScalingPolicies": null,
          "KillSignal": "",
          "Kind": "",
          "CSIPluginConfig": null,
          "Identity": {
            "Name": "default",
            "Audience": [
              "nomadproject.io"
            ],
            "ChangeMode": "",
            "ChangeSignal": "",
            "Env": false,
            "File": false,
            "Filepath": "",
            "ServiceName": "",
            "TTL": 0
          },
          "Identities": null,
          "Actions": null,
          "Schedule": null
        },
        {
          "Name": "quiet-sky-baemgz-storage-clone",
          "Driver": "raw_exec",
          "User": "guepard",
          "Config": {
            "command": "gfs",
            "args": [
              "dataset",
              "create",
              "-v",
              "quiet-sky-baemgz",
              "-u",
              999,
              "-g",
              999,
              "-C",
              "af8440a8-d594-4788-82a2-7b63438ea76d",
              "-q",
              "512"
            ]
          },
          "Env": null,
          "Services": null,
          "Vault": null,
          "Consul": null,
          "Templates": null,
          "Constraints": [
            {
              "LTarget": "${meta.storage}",
              "RTarget": "true",
              "Operand": "="
            },
            {
              "LTarget": "${meta.datacenter}",
              "RTarget": "us-west-aws",
              "Operand": "="
            }
          ],
          "Affinities": null,
          "Resources": {
            "CPU": 10,
            "Cores": 0,
            "MemoryMB": 10,
            "MemoryMaxMB": 0,
            "DiskMB": 0,
            "IOPS": 0,
            "Networks": null,
            "Devices": null,
            "NUMA": null,
            "SecretsMB": 0
          },
          "RestartPolicy": {
            "Attempts": 3,
            "Interval": 86400000000000,
            "Delay": 15000000000,
            "Mode": "fail",
            "RenderTemplates": false
          },
          "DispatchPayload": null,
          "Lifecycle": null,
          "Meta": {
            "deployment_id": "8bb0f962-842d-4c11-a048-1ed1ea6ad90c",
            "clone_id": "5f67dbb9-b7e1-4958-a95f-8234aed67431",
            "customer_id": "af8440a8-d594-4788-82a2-7b63438ea76d"
          },
          "KillTimeout": 5000000000,
          "LogConfig": {
            "MaxFiles": 10,
            "MaxFileSizeMB": 10,
            "Disabled": false
          },
          "Artifacts": null,
          "Leader": false,
          "ShutdownDelay": 0,
          "VolumeMounts": null,
          "ScalingPolicies": null,
          "KillSignal": "",
          "Kind": "",
          "CSIPluginConfig": null,
          "Identity": {
            "Name": "default",
            "Audience": [
              "nomadproject.io"
            ],
            "ChangeMode": "",
            "ChangeSignal": "",
            "Env": false,
            "File": false,
            "Filepath": "",
            "ServiceName": "",
            "TTL": 0
          },
          "Identities": null,
          "Actions": null,
          "Schedule": null
        }
      ],
      "EphemeralDisk": {
        "Sticky": false,
        "SizeMB": 300,
        "Migrate": false
      },
      "Meta": null,
      "ReschedulePolicy": {
        "Attempts": 1,
        "Interval": 86400000000000,
        "Delay": 5000000000,
        "DelayFunction": "constant",
        "MaxDelay": 0,
        "Unlimited": false
      },
      "Affinities": null,
      "Spreads": null,
      "Networks": null,
      "Consul": {
        "Namespace": "",
        "Cluster": "default",
        "Partition": ""
      },
      "Services": null,
      "Volumes": null,
      "ShutdownDelay": null,
      "StopAfterClientDisconnect": null,
      "MaxClientDisconnect": null,
      "PreventRescheduleOnLost": false
    }
  ],
  "Update": {
    "Stagger": 0,
    "MaxParallel": 0,
    "HealthCheck": "",
    "MinHealthyTime": 0,
    "HealthyDeadline": 0,
    "ProgressDeadline": 0,
    "AutoRevert": false,
    "AutoPromote": false,
    "Canary": 0
  },
  "Multiregion": null,
  "Periodic": null,
  "ParameterizedJob": null,
  "Dispatched": false,
  "DispatchIdempotencyToken": "",
  "Payload": null,
  "Meta": null,
  "ConsulToken": "",
  "ConsulNamespace": "",
  "VaultToken": "",
  "VaultNamespace": "",
  "NomadTokenID": "f672e076-01c9-676f-234b-b105c2c28a94",
  "Status": "dead",
  "StatusDescription": "",
  "Stable": false,
  "Version": 0,
  "SubmitTime": 1747043013474680800,
  "CreateIndex": 296582,
  "ModifyIndex": 296597,
  "JobModifyIndex": 296582,
  "UI": null,
  "VersionTag": null,
  "meta": {
    "index": "296597"
  }
}