# ----------------------
# Stage 1: Build with Maven (Builder Image)
# ----------------------
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Clone only the required branch directly (best practice)
RUN git clone --branch containers --single-branch https://github.com/Ahmedlekan/devops-project.git

WORKDIR /app/devops-project

# Clean and build application (skip tests to speed up CI build)
RUN mvn --batch-mode clean package -DskipTests

# ----------------------
# Stage 2: Tomcat + deploy artifact (Final runtime Image)
# ----------------------
FROM tomcat:10.1.20-jre21

# Remove default apps to keep image smaller
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy only the final WAR from builder (no source code, no Maven, no Git)
COPY --from=builder /app/devops-project/target/*vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

# Clean additional Tomcat docs/example apps
RUN rm -rf /usr/local/tomcat/webapps/docs \
    /usr/local/tomcat/webapps/examples \
    /usr/local/tomcat/webapps/manager \
    
# Expose Tomcat port
EXPOSE 8080

# Start Tomcat when container runs
CMD ["catalina.sh", "run"]
