Given /^my telephone number is "([^\"]*)"$/ do |phone_number|
  @ivr_client.generate_new_call_sid
  @ivr_client.phone_number = phone_number
end

Given /^I am testing the "([^\"]*)" workflow\.$/ do |workflow|
  @ivr_client.workflow_name = workflow
end

When /^I call the IVR\.$/ do
  @ivr_client.call_the_ivr
end

Then /^the IVR says "([^\"]*)"$/ do |phrase|
  @ivr_client.last_response['twml'].should include(phrase)
end

When /^I press (\d+)$/ do |digits|
  @ivr_client.input_to_workflow 'Digits' => digits
end

Then /^the IVR says$/ do |multiline|
  multiline.split(/\n/).each do |phrase|
    phrase.strip!
    @ivr_client.last_response['twml'].should include(phrase)
  end
end

Then /^I mash on the keys$/ do
  nums = '#*0123456789'
  input = '#'
  rand(10).to_i.times do
    input += nums[rand(nums.size)].to_s
  end
  @ivr_client.input_to_workflow 'Digits' => input
end

