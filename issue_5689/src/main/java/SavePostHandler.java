import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import java.util.HashMap;
import java.util.Map;

public class SavePostHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
	
	@Override
	public APIGatewayProxyResponseEvent handleRequest(final APIGatewayProxyRequestEvent event, final Context context) {
		Map<String, String> headers = new HashMap<>();
		headers.put("Content-Type", "application/json");
		
		APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent()
				.withHeaders(headers);
		
		try {
			return response.withStatusCode(404).withBody("{\"error\":\"error\"}");
		} catch (final Exception e) {
			return response.withStatusCode(500).withBody("{}");
		}
	}
}
