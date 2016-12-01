# Filter mails with a specific whitelist of email addresses and only leaves
# those in the 'to'.
class MailInterceptor
  # @param [Array<String>, #include?] whitelist
  def initialize(whitelist:, fallback: nil)
    @whitelist = whitelist
    @fallback = fallback
  end

  def delivering_email(mail)
    mail.to = mail.to.select do |recipient|
      @whitelist.include?(recipient)
    end
    mail.to = [@fallback] if @fallback && mail.to.empty?
  end
end
