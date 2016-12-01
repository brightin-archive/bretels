require 'spec_helper'

RSpec.describe MailInterceptor do
  subject { described_class.new(['john@example.com', 'eric@example.com']) }

  it 'is compatible with Mail interceptors' do
    expect(subject).to respond_to(:delivering_email)
  end

  it 'removes recipients from an email using a whitelist' do
    email = OpenStruct.new(to: ['john@example.com', 'graham@example.com'])
    expect {
      subject.delivering_email(email)
    }.to change { email.to }.to(['john@example.com'])
  end

  it 'sends the email to a fallback address when no recipients remain' do
    allow(ENV).to receive(:fetch).with('MAIL_INTERCEPTOR_FALLBACK')
      .and_return('terry@example.com')
    email = OpenStruct.new(to: ['graham@example.com'])
    expect {
      subject.delivering_email(email)
    }.to change { email.to }.to(['terry@example.com'])
  end
end
