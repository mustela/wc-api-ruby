require "minitest/autorun"
require "fakeweb"
require "json"
require "woocommerce_api"

class WooCommerceAPITest < Minitest::Test
  def setup
    @basic_auth = WooCommerce::API.new(
      "https://dev.test/",
      "user",
      "pass"
    )

    @oauth = WooCommerce::API.new(
      "http://dev.test/",
      "user",
      "pass"
    )

  end

  def test_basic_auth_get
    FakeWeb.register_uri(:get, "https://user:pass@dev.test/wc-api/v3/customers",
      :body => '{"customers":[]}',
      :content_type => "application/json"
    )
    response = @basic_auth.get "customers"

    assert_equal 200, response.code
  end

  def test_oauth_get
    FakeWeb.register_uri(:get, /http:\/\/dev\.test\/wc-api\/v3\/customers\?oauth_consumer_key=user&oauth_nonce=(.*)&(.*)oauth_signature_method=HMAC-SHA256&oauth_timestamp=(.*)/,
      :body => '{"customers":[]}',
      :content_type => "application/json"
    )
    response = @oauth.get "customers"

    assert_equal 200, response.code
  end

  def test_basic_auth_post
    FakeWeb.register_uri(:post, "https://user:pass@dev.test/wc-api/v3/products",
      :body => '{"products":[]}',
      :content_type => "application/json",
      :status => ["201", "Created"]
    )

    data = {
      product: {
        title: "Testing product"
      }
    }
    response = @basic_auth.post "products", data

    assert_equal 201, response.code
  end

  def test_oauth_post
    FakeWeb.register_uri(:post, /http:\/\/dev\.test\/wc-api\/v3\/products\?oauth_consumer_key=user&oauth_nonce=(.*)&(.*)oauth_signature_method=HMAC-SHA256&oauth_timestamp=(.*)/,
      :body => '{"products":[]}',
      :content_type => "application/json",
      :status => ["201", "Created"]
    )

    data = {
      product: {
        title: "Testing product"
      }
    }
    response = @oauth.post "products", data

    assert_equal 201, response.code
  end

  def test_basic_auth_put
    FakeWeb.register_uri(:put, "https://user:pass@dev.test/wc-api/v3/products/1234",
      :body => '{"customers":[]}',
      :content_type => "application/json"
    )

    data = {
      product: {
        title: "Updating product title"
      }
    }
    response = @basic_auth.put "products/1234", data

    assert_equal 200, response.code
  end

  def test_oauth_put
    FakeWeb.register_uri(:put, /http:\/\/dev\.test\/wc-api\/v3\/products\?oauth_consumer_key=user&oauth_nonce=(.*)&(.*)oauth_signature_method=HMAC-SHA256&oauth_timestamp=(.*)/,
      :body => '{"products":[]}',
      :content_type => "application/json"
    )

    data = {
      product: {
        title: "Updating product title"
      }
    }
    response = @oauth.put "products", data

    assert_equal 200, response.code
  end

  def test_basic_auth_delete
    FakeWeb.register_uri(:delete, "https://user:pass@dev.test/wc-api/v3/products/1234?force=true",
      :body => '{"message":"Permanently deleted product"}',
      :content_type => "application/json",
      :status => ["202", "Accepted"]
    )

    response = @basic_auth.delete "products/1234?force=true"

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.to_json
  end

  def test_oauth_put
    FakeWeb.register_uri(:delete, /http:\/\/dev\.test\/wc-api\/v3\/products\/1234\?force=true&oauth_consumer_key=user&oauth_nonce=(.*)&(.*)oauth_signature_method=HMAC-SHA256&oauth_timestamp=(.*)/,
      :body => '{"message":"Permanently deleted product"}',
      :content_type => "application/json",
      :status => ["202", "Accepted"]
    )

    response = @oauth.delete "products/1234?force=true"

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.to_json
  end
end
