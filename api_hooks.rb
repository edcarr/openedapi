require 'json'
include DreddHooks::Methods

stash     = {}
stash['static_group_id'] = '31775'
CLIENT_ID = ENV['CLIENT_ID']
SECRET    = ENV['SECRET']


before 'Accounts > Access Token > Getting your Access Token' do |transaction|
  request_body = JSON.parse transaction['request']['body']
  request_body['username']  = 'testuser' 

  # until dredd lets me access request for all responses I will look for second call testing 400
  # here i remove token so request does not load user and then try to access a user from a different provider
  # this should result in 400
  if transaction['request']['headers']['Authorization']
    transaction['request']['headers']['Authorization'] = ""
    request_body['username']  = "lucastest1_original@opened.io"
  end 
  request_body['client_id'] = CLIENT_ID
  request_body['secret']    = SECRET
  
  transaction['request']['body'] = request_body.to_json
end

# hook to retrieve session on a login
after 'Accounts > Access Token > Getting your Access Token' do |transaction|
  #if token has been set then skip
  unless stash['token']
    parsed_body = JSON.parse transaction['real']['body']
    puts "token is #{parsed_body['access_token']}"
    stash['token'] = parsed_body['access_token']
  end
end

# hook to set the session cookie in all following requests
before_each do |transaction|
  unless stash['token'].nil?
    transaction['request']['headers']['Authorization'] = "Bearer " + stash['token']
  end
end

after "Manage teacher's classes and students > Teacher's Classes > Create a New Class" do |transaction|
  parsed_body = JSON.parse transaction['real']['body']
  stash['group_id'] = parsed_body['class']['id'].to_s
end

after "Manage teacher's classes and students > Teacher's Classes > Create a Student" do |transaction|
  parsed_body = JSON.parse transaction['real']['body']
  stash['student_id'] = parsed_body['student']['id'].to_s
end

after "User > Search for a User > Search" do |transaction|
  puts "inside after search for a user"
  parsed_body =transaction['real']
  puts "body is #{parsed_body}"
end

before "Manage teacher's classes and students > Teacher's Classes > Create a Student" do |transaction|
  request_body = JSON.parse transaction['request']['body']
  request_body['student']['username'] = 'studentapi'
  request_body['student']['class_ids'] = []
  request_body['student']['email'] = nil
  transaction['request']['body'] = request_body.to_json
end

before "Manage teacher's classes and students > Teacher's Students > Update Student" do |transaction|
  transaction['fullPath'].gsub! '123', stash['student_id']
end

before "Resources > Search Resources > Search > Example 1" do |transaction|
  path = transaction['fullPath'].split("?")[0]
  transaction['fullPath'] =  "#{path}?license=free"
end

before "Resources > Search Resources > Search > Example 2" do |transaction|
  path = transaction['fullPath'].split("?")[0]
  transaction['fullPath'] =  "#{path}?limit=5&offset=0&license=free&schema_org=true"
end

after "Assessment Results > Get Assessment Results > GET" do |transaction|
  parsed_body = JSON.parse transaction['real']['body']
end

before "Manage teacher's classes and students > Teacher's Students > Remove a Student" do |transaction|
  transaction['fullPath'].gsub! '123', stash['student_id']
end

before "Manage teacher's classes and students > Teacher's Classes > Get Class" do |transaction|
  transaction['fullPath'].gsub! '123', stash['group_id']
end

before "Manage teacher's classes and students > Teacher's Classes > Update Class" do |transaction|
  transaction['fullPath'].gsub! '123', stash['group_id']
end

before "Manage teacher's classes and students > Teacher's Classes > Remove a Class" do |transaction|
  transaction['fullPath'].gsub! '123', stash['group_id']
end

before "Manage teacher's classes and students > Teacher's Students > Get Student" do |transaction|
  transaction['fullPath'].gsub! '123', stash['student_id']
end

before "User > Update a User > Update" do |transaction|
  request_body = JSON.parse transaction['request']['body']
  request_body['school_nces_id']= 360008702155
  request_body['first_name'] = "Update User first name"
  request_body['last_name'] = "Update User last name"
  transaction['request']['body'] = request_body.to_json
end

before "Manage teacher's classes and students > Teacher's Classes > Add existing students to the Class" do |transaction|
  request_body = JSON.parse transaction['request']['body']
  request_body['student_ids'] = [stash['student_id']]
  transaction['request']['body'] = request_body.to_json
  transaction['fullPath'].gsub! '123', stash['static_group_id']
end

before "Manage teacher's classes and students > Teacher's Classes > Remove students from the Class" do |transaction|
  request_body = JSON.parse transaction['request']['body']
  request_body['student_ids'] = [stash['student_id']]
  transaction['request']['body'] = request_body.to_json
  transaction['fullPath'].gsub! '123', stash['static_group_id']
end

before "Manage teacher's classes and students > Teacher's Classes > Remove a Class" do |transaction|
  transaction['fullPath'].gsub! '123', stash['group_id']
end

# skip create tests

before "User > Create a User > Create" do |transaction|
  transaction['skip'] = true
end

before "Resources > Create Resource > Create" do |transaction|
  transaction['skip'] = true
end

before "Resources > Update Resource > Update" do |transaction|
  transaction['skip'] = true
end

before "School > Create a School > Create" do |transaction|
  transaction['skip'] = true
end


