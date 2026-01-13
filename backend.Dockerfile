FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

COPY chatbot_back/.mvn/ .mvn/
COPY chatbot_back/mvnw chatbot_back/pom.xml ./
RUN chmod +x mvnw

RUN ./mvnw -q -DskipTests dependency:go-offline

COPY chatbot_back/src/ src/
RUN ./mvnw -q -DskipTests package

FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app/app.jar"]
