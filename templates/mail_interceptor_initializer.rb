if ENV.key?('MAIL_INTERCEPTOR_WHITELIST')
  ActionMailer::Base.register_interceptor(
    MailWhitelist.new(
      whitelist: ENV.fetch('MAIL_INTERCEPTOR_WHITELIST').split(','),
      fallback: ENV['MAIL_INTERCEPTOR_FALLBACK']
    )
  )
end
