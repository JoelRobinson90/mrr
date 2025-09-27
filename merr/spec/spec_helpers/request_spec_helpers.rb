# frozen_string_literal: true

# typed: true
module RequestSpecHelpers
  # V1 front end (sync)
  # Selectors to get react element and props passed from the Rails controller
  def react_element(component_name)
    doc = Nokogiri::HTML(response.body)
    doc.at_css("[data-react-class=\"#{component_name}\"]")
  end

  def react_props(component_name)
    element = react_element(component_name)
    raise "React component #{component_name} not found" unless element

    JSON.parse react_element(component_name)["data-react-props"]
  end

  # V2 front end (async)
  # GraphQL helpers
  def post_graphql_request(params)
    post graphql_path, params: params.to_json, headers: {"content-type": "application/json"}
  end

  def get_graphql_response(allow_errors: false)
    body = JSON.parse(response.body)
    raise GraphqlError, body if !allow_errors && body["errors"]

    body
  end

  class GraphqlError < StandardError; end
end
