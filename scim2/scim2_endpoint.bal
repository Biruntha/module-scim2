// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

# SCIM2 Client Endpoint configuration object.
# + clientConfig - HTTP client endpoint configuration object
public type Scim2Configuration record {
    http:ClientEndpointConfig clientConfig;
};

# SCIM2 Client.
# + scim2Config - SCIM2 client endpoint configuration object
# + scim2Connector - SCIM2 Connector object
public type Client object {
    public Scim2Configuration scim2Config = {};
    public ScimConnector scim2Connector = new;

    # Initialize the SCiM2 endpoint.
    # + config - SCIM2 configuration object
    public function init(Scim2Configuration config);

    # Returns the connector that client code uses.
    # + return - SCIM2 Client
    public function getCallerActions() returns ScimConnector;
};

function Client::init(Scim2Configuration config) {
    self.scim2Connector.baseUrl = config.clientConfig.url;
    self.scim2Connector.httpClient.init(config.clientConfig);
}

function Client::getCallerActions() returns ScimConnector {
    return self.scim2Connector;
}
