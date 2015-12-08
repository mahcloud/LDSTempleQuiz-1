begin
  Figaro.require_keys('APP_SECRET', 'DATABASE_URL', 'RAYGUN_APIKEY')
rescue NameError
end
