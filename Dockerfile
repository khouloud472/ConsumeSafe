################################
# Build stage
################################
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /build

# Cache Maven dependencies
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source code
COPY src ./src
RUN mvn -B clean package -DskipTests

################################
# Runtime stage
################################
FROM eclipse-temurin:21-jre-jammy

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75 -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

WORKDIR /app

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy JAR from build stage
COPY --from=build /build/target/*.jar app.jar
RUN chown appuser:appgroup app.jar && chmod 500 app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=5 --start-period=60s \
    CMD curl -f http://localhost:8082/api/products/health || exit 1

# Run as non-root user
USER appuser

# Expose port
EXPOSE 8082

# Start application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
