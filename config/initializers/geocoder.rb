if Rails.env.test?
  Geocoder.configure(:lookup => :test)
  Geocoder::Lookup::Test.add_stub('New York, NY', [
    {
      latitude: 40.7143528,
      longitude: -74.0059731,
      address: 'New York, NY, USA',
      state: 'New York',
      state_code: 'NY',
      country: 'United States',
      country_code: 'US'
    }]
  )
  Geocoder::Lookup::Test.add_stub('Boston, MA, USA', [
   {
     latitude: 42.3601891,
     longitude: -71.0508825,
     address: 'Boston, MA, USA',
     state: 'Massachusetts',
     state_code: 'MA',
     country: 'United States',
     country_code: 'US'
   }]
  )
  Geocoder::Lookup::Test.set_default_stub(
    [{
       latitude: 42.3783904,
       longitude: -71.1129097,
       address: 'Cambridge, MA, USA',
       state: 'Massachusetts',
       state_code: 'MA',
       country: 'United States',
       country_code: 'US'
    }]
  )
else
  Geocoder.configure(
      # geocoding options
      # :timeout      => 3,           # geocoding service timeout (secs)
      :lookup       => :google,     # name of geocoding service (symbol)
      # :language     => :en,         # ISO-639 language code
      :use_https    => true,       # use HTTPS for lookup requests? (if supported)
      # :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
      # :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
      :api_key      => ENV['GOOGLE_GEOCODER_KEY'],         # API key for geocoding service
      # :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
      # :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

      # exceptions that should not be rescued by default
      # (if you want to implement custom error handling);
      # supports SocketError and TimeoutError
      # :always_raise => [],

      # calculation options
      :units     => :km,       # :km for kilometers or :mi for miles
      # :distances => :linear    # :spherical or :linear
  )
end
