//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDI   TIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
import ballerina/http;
import ballerina/mime;

# Object for SCIM2 endpoint.
# + baseUrl - Base URL of the REST API
# + httpClient - HTTP client endpoint
public type ScimConnector object {
    public string baseUrl;
    public http:Client httpClient;

    # Returns a list of user records if found or error if any error occured.
    # + return - If success, returns list of User objects, else returns error object
    public function getListOfUsers() returns (User[]|error);

    # Returns a list of group records if found or error if any error occured.
    # + return - If success, returns list of Group objects, else returns error object
    public function getListOfGroups() returns (Group[]|error);

    # Returns the user that is currently authenticated.
    # + return - If success, returns User object, else returns error object
    public function getMe() returns (User|error);

    # Returns a group record with the specified group name if found.
    # + groupName - Name of the group
    # + return - If success, returns Group object, else returns error object
    public function getGroupByName(string groupName) returns (Group|error);

    # Returns a user record with the specified username if found.
    # + userName - User name of the user
    # + return - If success, returns User object, else returns error object
    public function getUserByUsername(string userName) returns (User|error);

    # Create a group in the user store.
    # + crtGroup - Group record with the group details
    # + return - If success, returns string message with status, else returns error object
    public function createGroup(Group crtGroup) returns (string|error);

    # Create a user in the user store.
    # + user - User record with the user details
    # + return - If success, returns string message with status, else returns error object
    public function createUser(User user) returns (string|error);

    # Add a user specified by username to the group specified by group name.
    # + userName - User name of the user
    # + groupName - Name of the group
    # + return - If success, returns string message with status, else returns error object
    public function addUserToGroup(string userName, string groupName) returns (string|error);

    # Remove a user specified by username from the group specified by group name.
    # + userName - User name of the user
    # + groupName - Name of the group
    # + return - If success, returns string message with status, else returns error object
    public function removeUserFromGroup(string userName, string groupName) returns (string|error);

    # Returns whether the user specified by username belongs to the group specified by groupname.
    # + userName - User name of the user
    # + groupName - Name of the group
    # + return - If success, returns boolean value, else returns error object
    public function isUserInGroup(string userName, string groupName) returns (boolean|error);

    # Delete a user from user store.
    # + userName - User name of the user
    # + return - If success, returns string message with status, else returns error object
    public function deleteUserByUsername(string userName) returns (string|error);

    # Delete a group from user store.
    # + groupName - User name of the user
    # + return - String message with status
    public function deleteGroupByName(string groupName) returns (string|error);

    # Update a simple attribute of user.
    # + id - ID of the user
    # + valueType - The attribute name to be updated
    # + newValue - The new value of the attribute
    # + return - If success, returns string message with status, else returns error object
    public function updateSimpleUserValue(string id, string valueType, string newValue) returns
                                                                                                (string|error);

    # Update emails addresses of a user.
    # + id - ID of the user
    # + emails - List of new emails of the user
    # + return - If success, returns string message with status, else returns error object
    public function updateEmails(string id, Email[] emails) returns (string|error);

    # Update addresses of a user.
    # + id - ID of the user
    # + addresses - List of new addresses of the user
    # + return - If success, returns string message with status, else returns error object
    public function updateAddresses(string id, Address[] addresses) returns (string|error);

    # Update a user.
    # + user - User record with new user values
    # + return - If success, returns string message with status, else returns error object
    public function updateUser(User user) returns (string|error);
};

function ScimConnector::getListOfUsers() returns (User[]|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Listing users failed. ";

    var res = httpEP->get(SCIM_USER_END_POINT, message = request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                        User[] userList = [];
                        if (noOfResults.equalsIgnoreCase("0")) {
                            return userList;
                        } else {
                            payload = payload[SCIM_RESOURCES];
                            int k = 0;
                            foreach element in payload {
                                User user = {};
                                user = convertJsonToUser(element);
                                userList[k] = user;
                                k = k + 1;
                            }
                            return userList;
                        }
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            } else {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            }
        }
    }
}

function ScimConnector::getListOfGroups() returns (Group[]|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage = "Listing groups failed. ";

    var res = httpEP->get(SCIM_GROUP_END_POINT, message = request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                        Group[] groupList = [];
                        if (noOfResults.equalsIgnoreCase("0")) {
                            return groupList;
                        } else {
                            payload = payload[SCIM_RESOURCES];
                            int k = 0;
                            foreach element in payload {
                                Group group1 = {};
                                group1 = convertJsonToGroup(element);
                                groupList[k] = group1;
                                k = k + 1;
                            }
                            return groupList;
                        }
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            } else {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            }
        }
    }
}

function ScimConnector::getMe() returns (User|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    User user = {};

    string failedMessage = "Getting currently authenticated user failed. ";

    var res = httpEP->get(SCIM_ME_ENDPOINT, message = request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        user = convertJsonToUser(payload);
                        return user;
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            } else {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            }
        }
    }
}

function ScimConnector::getGroupByName(string groupName) returns (Group|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string s = SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName;
    var res = httpEP->get(s, message = request);
    match res {
        error err => {
            Error = { message: "Failed to get Group " + groupName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedGroup = resolveGroup(groupName, response);
            return receivedGroup;
        }
    }
}

function ScimConnector::getUserByUsername(string userName) returns (User|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    var res = httpEP->get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, message = request);
    match res {
        error err => {
            Error = { message: "Failed to get User " + userName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedUser = resolveUser(userName, response);
            return receivedUser;
        }
    }
}

function ScimConnector::createGroup(Group crtGroup) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Creating group:" + crtGroup.displayName + " failed. ";

    request.addHeader(mime:CONTENT_TYPE, mime:APPLICATION_JSON);

    json jsonPayload = convertGroupToJson(crtGroup);
    request.setJsonPayload(jsonPayload);
    var res = httpEP->post(SCIM_GROUP_END_POINT, request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            if (statusCode == HTTP_CREATED) {
                return "Group Created";
            }
            else if (statusCode == HTTP_UNAUTHORIZED) {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            } else {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        Error = { message: failedMessage + (payload.detail.toString()) };
                        return Error;
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            }
        }
    }
}

function ScimConnector::createUser(User user) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Creating user:" + user.userName + " failed. ";

    if (user.emails != null) {
        foreach email in user.emails {
            if (!email["type"].equalsIgnoreCase(SCIM_WORK) && !email["type"].equalsIgnoreCase(SCIM_HOME)
            && !email["type"].equalsIgnoreCase(SCIM_OTHER)) {
                Error = { message: failedMessage + "Email should either be home or work" };
                return Error;
            }
        }
    }
    if (user.addresses != null) {
        foreach address in user.addresses {
            if (!address["type"].equalsIgnoreCase(SCIM_WORK) && !address["type"].equalsIgnoreCase(SCIM_HOME)
            && !address["type"].equalsIgnoreCase(SCIM_OTHER)) {
                Error = { message: failedMessage + "Address type should either be work or home" };
                return Error;
            }
        }
    }
    if (user.phoneNumbers != null) {
        foreach phone in user.phoneNumbers {
            if (!phone["type"].equalsIgnoreCase(SCIM_WORK) && !phone["type"].equalsIgnoreCase(SCIM_HOME)
            && !phone["type"].equalsIgnoreCase(SCIM_MOBILE)
            && !phone["type"].equalsIgnoreCase(SCIM_FAX)
            && !phone["type"].equalsIgnoreCase(SCIM_PAGER)
            && !phone["type"].equalsIgnoreCase(SCIM_OTHER)) {
                Error = { message: failedMessage + "Phone number type should be work,mobile,fax,pager,home or other" };
                return Error;
            }
        }
    }
    if (user.photos != null) {
        foreach photo in user.photos {
            if (!photo["type"].equalsIgnoreCase(SCIM_PHOTO) && !photo["type"].equalsIgnoreCase(SCIM_THUMBNAIL)) {
                Error = { message: failedMessage + "Photo type should either be photo or thumbnail" };
                return Error;
            }
        }
    }

    json jsonPayload = convertUserToJson(user, "create");

    request.addHeader(mime:CONTENT_TYPE, mime:APPLICATION_JSON);
    request.setJsonPayload(jsonPayload);
    var res = httpEP->post(SCIM_USER_END_POINT, request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            if (statusCode == HTTP_CREATED) {
                return "User Created";
            }
            else if (statusCode == HTTP_UNAUTHORIZED) {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            } else {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        Error = { message: failedMessage + (payload.detail.toString()) };
                        return Error;
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            }
        }
    }
}

function ScimConnector::addUserToGroup(string userName, string groupName) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Adding user:" + userName + " to group:" + groupName + " failed.";

    //check if user valid
    http:Request requestUser = new();
    User user = {};
    var resUser = httpEP->get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName,
        message = requestUser);
    match resUser {
        error err => {
            Error = { message: "Failed to get User " + userName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedUser = resolveUser(userName, response);
            match receivedUser {
                User usr => {
                    user = usr;
                }
                error userError => {
                    Error = { message: failedMessage + userError.message };
                    return Error;
                }
            }
        }
    }
    //check if group valid
    http:Request requestGroup = new();
    Group gro = {};
    var resGroup = httpEP->get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName,
        message = requestGroup);
    match resGroup {
        error err => {
            Error = { message: "Failed to get Group " + groupName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedGroup = resolveGroup(groupName, response);
            match receivedGroup {
                Group grp => {
                    gro = grp;
                }
                error groupError => {
                    Error = { message: failedMessage + groupError.message };
                    return Error;
                }
            }
        }
    }
    //create request body
    string value = user.id;
    string ref = self.baseUrl + SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + value;
    string url = SCIM_GROUP_END_POINT + SCIM_FILE_SEPERATOR + gro.id;

    json body = SCIM_GROUP_PATCH_ADD_BODY;
    body.Operations[0].value.members[0].display = userName;
    body.Operations[0].value.members[0][SCIM_REF] = ref;
    body.Operations[0].value.members[0].value = value;

    request.addHeader(mime:CONTENT_TYPE, mime:APPLICATION_JSON);
    request.setJsonPayload(body);
    var res = httpEP->patch(url, request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            if (statusCode == HTTP_OK) {
                return "User Added";
            }
            else if (statusCode == HTTP_UNAUTHORIZED) {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            } else {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        Error = { message: failedMessage + (payload.detail.toString()) };
                        return Error;
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            }
        }
    }
}

function ScimConnector::removeUserFromGroup(string userName, string groupName) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Removing user:" + userName + " from group:" + groupName + " failed.";

    //check if user valid
    http:Request requestUser = new();
    User user = {};
    var resUser = httpEP->get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME +
            userName, message = requestUser);
    match resUser {
        error err => {
            Error = { message: "Failed to get User " + userName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedUser = resolveUser(userName, response);
            match receivedUser {
                User usr => {
                    user = usr;
                }
                error userError => {
                    Error = { message: failedMessage + userError.message };
                    return Error;
                }
            }
        }
    }

    //check if group valid
    Group gro = {};
    http:Request groupRequest = new();
    var resGroup = httpEP->get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME +
            groupName, message = groupRequest);
    match resGroup {
        error err => {
            Error = { message: "Failed to get Group " + groupName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedGroup = resolveGroup(groupName, response);
            match receivedGroup {
                Group grp => {
                    gro = grp;
                }
                error groupError => {
                    Error = { message: failedMessage + groupError.message };
                    return Error;
                }
            }
        }
    }
    //create request body
    json body = SCIM_GROUP_PATCH_REMOVE_BODY;
    string path = "members[display eq " + userName + "]";
    body.Operations[0].path = path;
    string url = SCIM_GROUP_END_POINT + SCIM_FILE_SEPERATOR + gro.id;

    request.addHeader(mime:CONTENT_TYPE, mime:APPLICATION_JSON);
    request.setJsonPayload(body);
    var res = httpEP->patch(url, request);
    match res {
        error err => {
            Error = { message: failedMessage + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            if (statusCode == HTTP_OK) {
                return "User Removed";
            }
            else if (statusCode == HTTP_UNAUTHORIZED) {
                Error = { message: failedMessage + response.reasonPhrase };
                return Error;
            } else {
                var received = response.getJsonPayload();
                match received {
                    json payload => {
                        Error = { message: failedMessage + (payload.detail.toString()) };
                        return Error;
                    }
                    error e => {
                        Error = { message: failedMessage + e.message, cause: e.cause };
                        return Error;
                    }
                }
            }
        }
    }
}

function ScimConnector::isUserInGroup(string userName, string groupName) returns (boolean|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};
    User user = {};

    var res = httpEP->get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, message = request);
    match res {
        error err => {
            Error = { message: "Failed to get User " + userName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedUser = resolveUser(userName, response);
            match receivedUser {
                User usr => {
                    user = usr;
                    foreach gro in user.groups {
                        if (gro.displayName.equalsIgnoreCase(groupName)) {
                            return true;
                        }
                    }
                    return false;
                }
                error userError => {
                    Error = { message: "failed to resolve user " + userError.message };
                    return Error;
                }
            }
        }
    }
}

function ScimConnector::deleteUserByUsername(string userName) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();

    string failedMessage;
    failedMessage = "Deleting user:" + userName + " failed. ";

    //get user
    http:Request userRequest = new();
    User user = {};
    error Error = {};
    var resUser = httpEP->get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName,
        message = userRequest);
    match resUser {
        error err => {
            Error = { message: "Failed to get User " + userName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedUser = resolveUser(userName, response);
            match receivedUser {
                User usr => {
                    user = usr;
                    string userId = user.id;
                    var res = httpEP->delete(SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + userId, request);
                    match res {
                        error err => {
                            Error = { message: failedMessage + err.message, cause: err.cause };
                            return Error;
                        }
                        http:Response resp => {
                            if (resp.statusCode == HTTP_NO_CONTENT) {
                                return "deleted";
                            }
                            Error = { message: failedMessage + response.reasonPhrase };
                            return Error;
                        }
                    }
                }
                error userError => {
                    Error = { message: failedMessage + userError.message };
                    return Error;
                }
            }
        }
    }
}

function ScimConnector::deleteGroupByName(string groupName) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    http:Request request = new();
    error Error = {};

    string failedMessage;
    failedMessage = "Deleting group:" + groupName + " failed. ";

    //get the group
    http:Request groupRequest = new();
    Group gro = {};
    string s = SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName;
    var resGroup = httpEP->get(s, message = groupRequest);
    match resGroup {
        error err => {
            Error = { message: "Failed to get Group " + groupName + "." + err.message, cause: err.cause };
            return Error;
        }
        http:Response response => {
            var receivedGroup = resolveGroup(groupName, response);
            match receivedGroup {
                Group grp => {
                    gro = grp;
                    string groupId = gro.id;
                    var res = httpEP->delete(SCIM_GROUP_END_POINT + SCIM_FILE_SEPERATOR + groupId, request);
                    match res {
                        error err => {
                            Error = { message: failedMessage + err.message, cause: err.cause };
                            return Error;
                        }
                        http:Response resp => {
                            if (resp.statusCode == HTTP_NO_CONTENT) {
                                return "deleted";
                            }
                            Error = { message: failedMessage + response.reasonPhrase };
                            return Error;
                        }
                    }
                }
                error groupError => {
                    Error = { message: failedMessage + groupError.message };
                    return Error;
                }
            }
        }
    }
}

function ScimConnector::updateSimpleUserValue(string id, string valueType, string newValue)
                                   returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    error Error = {};

    if (id.equalsIgnoreCase("") || newValue == "") {
        Error = { message: "User and new " + valueType + " should be valid" };
        return Error;
    }

    http:Request request = new();
    var bodyOrError = createUpdateBody(valueType, newValue);
    match bodyOrError {
        json body => {
            request = createRequest(body);

            string url = SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + id;
            var res = httpEP->patch(url, request);
            match res {
                error err => {
                    Error = { message: err.message };
                    return Error;
                }
                http:Response response => {
                    if (response.statusCode == HTTP_OK) {
                        return valueType + " updated";
                    }
                    Error = { message: response.reasonPhrase };
                    return Error;
                }
            }
        }
        error err => {
            Error = { message: "Updating " + valueType + " of user failed. " + err.message };
            return Error;
        }
    }
}

function ScimConnector::updateEmails(string id, Email[] emails) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    error Error = {};

    if (id.equalsIgnoreCase("")) {
        Error = { message: "User should be valid" };
        return Error;
    }

    http:Request request = new();

    json[] emailList = [];
    json email;
    int i;
    foreach emailAddress in emails {
        if (!emailAddress.^"type".equalsIgnoreCase(SCIM_WORK) && !emailAddress.^"type".equalsIgnoreCase(SCIM_HOME)) {
            Error = { message: "Email type should be defiend as either home or work" };
            return Error;
        }
        email = convertEmailToJson(emailAddress);
        emailList[i] = email;
        i = i + 1;
    }
    json body = SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = { "emails": emailList };

    request = createRequest(body);

    string url = SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + id;
    var res = httpEP->patch(url, request);
    match res {
        error err => {
            Error = { message: err.message };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                return "Email updated";
            }
            Error = { message: response.reasonPhrase };
            return Error;
        }
    }
}

function ScimConnector::updateAddresses(string id, Address[] addresses) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    error Error = {};

    if (id.equalsIgnoreCase("")) {
        Error = { message: "User should be valid" };
        return Error;
    }

    http:Request request = new();

    json[] addressList = [];
    json element;
    int i;
    foreach address in addresses {
        if (!address.^"type".equalsIgnoreCase(SCIM_WORK) && !address.^"type".equalsIgnoreCase(SCIM_HOME)) {
            Error = { message: "Address type is required and it should either be work or home" };
            return Error;
        }
        element = convertAddressToJson(address);
        addressList[i] = element;
        i = i + 1;
    }
    json body = SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = { "addresses": addressList };

    request = createRequest(body);

    string url = SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + id;
    var res = httpEP->patch(url, request);
    match res {
        error err => {
            Error = { message: err.message };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                return "Address updated";
            }
            Error = { message: response.reasonPhrase };
            return Error;
        }
    }
}

function ScimConnector::updateUser(User user) returns (string|error) {
    endpoint http:Client httpEP = self.httpClient;
    error Error = {};
    http:Request request = new();

    json body = convertUserToJson(user, "update");
    request = createRequest(body);
    string url = SCIM_USER_END_POINT + SCIM_FILE_SEPERATOR + user.id;
    var res = httpEP->put(url, request);
    match res {
        error err => {
            Error = { message: err.message };
            return Error;
        }
        http:Response response => {
            if (response.statusCode == HTTP_OK) {
                return "User updated";
            }
            Error = { message: response.reasonPhrase };
            return Error;
        }
    }
}