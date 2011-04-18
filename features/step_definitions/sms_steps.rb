When /^I text "([^\"]*)"$/ do |body|
  @ivr_client.send_sms body
end

Then /^I recieve an sms that contains "([^\"]*)"$/ do |phrase|
  @ivr_client.last_response['twml'].should include(phrase)
end

