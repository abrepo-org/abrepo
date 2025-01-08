class ApplicationMailer < ActionMailer::Base

  # want to log delivery errors
  # but proceed as if they weren't raised
  # (config.action_mailer.raise_delivery_errors = false)
  rescue_from EOFError,
              IOError,
              Timeout::Error,
              Errno::ECONNRESET,
              Errno::ECONNABORTED,
              Errno::EPIPE,
              Errno::ETIMEDOUT,
              Net::SMTPAuthenticationError,
              Net::SMTPServerBusy,
              Net::SMTPSyntaxError,
              Net::SMTPUnknownError,
              Net::SMTPFatalError,
              OpenSSL::SSL::SSLError,
              Exception do |e|

    Rails.logger.error "Mailer Exception"
    Rails.logger.error e.inspect
  end


end
