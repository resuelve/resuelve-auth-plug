alias ResuelveAuth.TokenData
alias ResuelveAuth.Helpers.TokenHelper
time = DateTime.to_unix(DateTime.utc_now(), :millisecond)
options = [secret: "super-secret-key", limit_time: 4]

token_data = %TokenData{
      service: "my-api",
      role: "user",
      meta: "metadata",
      timestamp: time
    }
