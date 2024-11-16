# Copyright 2024 weooh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Signature Method v3
# get more information from github.com/TencentCloud/signature-process-demo,
# at signature-v3/bash/signv3_no_xdd.sh
# usage: build_authorization <action> <version> <timestamp> <payload>
__URLHOST="dnspod.tencentcloudapi.com"
__METHOD="POST"
__CONTENT_TYPE="application/json"

__SECRET_ID="x"
__SECRET_KEY="x"

__SERVICE=$(printf %s "$__URLHOST" | cut -d '.' -f1)
__REGION=""
#  __ACTION=$1
__ACTION="ModifyRecord"
#  __VERSION=$2
__VERSION="2021-03-23"
__ALGORITHM="TC3-HMAC-SHA256"
#  __TIMESTAMP=$3
__TIMESTAMP=1731726323
__DATE=$(date -u -d @$__TIMESTAMP +"%Y-%m-%d")
#  __PAYLOAD=$4
__PAYLOAD='{"Domain":"zoltanqy.xyz","RecordType":"A","SubDomain":"test"}'

# 步骤 1：拼接规范请求串
__CANONICAL_URI="/"
__CANONICAL_QUERYSTRING=""
__CANONICAL_HEADERS=$(
    cat <<EOF
content-type:$__CONTENT_TYPE
host:$__URLHOST
x-tc-action:$(echo $__ACTION | awk '{print tolower($0)}')
EOF
)
__SIGNED_HEADERS="content-type;host;x-tc-action"
__HASHED_REQUEST_PAYLOAD=$(echo -n "$__PAYLOAD" | openssl sha256 -hex | awk '{print $2}')
__CANONICAL_REQEUST=$(
    cat <<EOF
$__METHOD
$__CANONICAL_URI
$__CANONICAL_QUERYSTRING
$__CANONICAL_HEADERS

$__SIGNED_HEADERS
$__HASHED_REQUEST_PAYLOAD
EOF
)

echo "STEP1: ................."
echo "$__CANONICAL_REQEUST"

# 步骤 2：拼接待签名字符串
__CREDENTIAL_SCOPE="$__DATE/$__SERVICE/tc3_request"
__HASHED_CANONICAL_REQUEST=$(printf "$__CANONICAL_REQEUST" |
    openssl sha256 -hex | awk '{print $2}')
__STRING_TO_SIGN=$(
    cat <<EOF
$__ALGORITHM
$__TIMESTAMP
$__CREDENTIAL_SCOPE
$__HASHED_CANONICAL_REQUEST
EOF
)

echo ""
echo "STEP2 ................."
echo "$__STRING_TO_SIGN"

# 步骤 3：计算签名
__SECRET_DATE=$(printf "$__DATE" |
    openssl sha256 -hmac "TC3$__SECRET_KEY" | awk '{print $2}')
__SECRET_SERVICE=$(printf $__SERVICE |
    openssl dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_DATE" | awk '{print $2}')
__SECRET_SIGNING=$(printf "tc3_request" |
    openssl dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_SERVICE" | awk '{print $2}')
__SIGNATURE=$(printf "$__STRING_TO_SIGN" |
    openssl dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_SIGNING" | awk '{print $2}')

echo ""
echo "STEP3 ................."
echo "$__SIGNATURE"

# 步骤 4：拼接 Authorization
__AUTHORIZATION="$__ALGORITHM Credential=$__SECRET_ID/$__CREDENTIAL_SCOPE, \
SignedHeaders=$__SIGNED_HEADERS, Signature=$__SIGNATURE"

echo ""
echo "STEP3 ................."
echo "$__AUTHORIZATION"
