require 'sinatra'
require 'http'
require 'debug'

get '/' do
  result = HTTP.headers(
    'Content-Type' => 'application/json',
    'Authorization' => 'Bearer <token>'
  ).post(
    'https://grafana-api.prd.int.kaligo.com/api/ds/query',
    json: {
      queries: [
        refId: "A",
        expr: "sum by (partner) (increase(istio_requests_total))",
        datasourceId: 204,
        maxDataPoints: 1280
      ],
      from: "now-5m",
      to: "now"
    }
  )

  if result.status.success?
    original_data = result.parse
    puts original_data
    data = original_data['results']['A']['frames']
      .map do |frame|
        value_name = frame['schema']['fields'].find do |field|
          field['name'] == 'Value'
        end
        values = frame['data']['values']
        times = values[0].map { |time| Time.at(time.to_f / 1000) }

        { x: times, y: values[1], name: value_name['labels'].to_json }
      end

    <<-HTML
  <html>
    <head>
      <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    </head>
    <body>
      <h2>This is a Plotly example</h2>

      <div id="tester" style="width:90%;height:250px;"></div>

      <script>
        let TESTER = document.getElementById('tester');

        let data = #{data.to_json};

        Plotly.plot( TESTER, data, {
        margin: { t: 0 } }, {showSendToCloud:true} );
      </script>
    </body>
  </html>
    HTML
  else
    "Error: #{result.body}"
  end

end
