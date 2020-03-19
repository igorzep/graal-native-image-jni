GRAALVM = $(HOME)/graalvm-ce-19.2.1

clean:
	-rm src/*.class
	-rm src/*.h
	-rm *.jar
	-rm *.dylib
	-rm helloworld

src/HelloWorld.class: src/HelloWorld.java
	javac src/HelloWorld.java

src/HelloWorld.h: src/HelloWorld.java
	cd src && javac -h . HelloWorld.java

libHelloWorld.dylib: src/HelloWorld.h src/HelloWorld.c
	gcc -shared -Wall -Werror -I$(JAVA_HOME)/include \
	    -I$(JAVA_HOME)/include/darwin \
	    -o libHelloWorld.dylib -fPIC src/HelloWorld.c

HelloWorld.jar: src/HelloWorld.class src/manifest.txt
	cd src && jar cfm ../HelloWorld.jar manifest.txt HelloWorld.class

run-jar: HelloWorld.jar libHelloWorld.dylib
	LD_LIBRARY_PATH=./ java -jar HelloWorld.jar

helloworld: HelloWorld.jar libHelloWorld.dylib
	$(JAVA_HOME)/bin/native-image \
		-jar HelloWorld.jar \
		-H:Name=helloworld \
		-H:+ReportExceptionStackTraces \
		-H:ConfigurationFileDirectories=config-dir \
		--initialize-at-build-time \
		--verbose \
		--no-fallback \
		--no-server \
		"-J-Xmx1g" \
		-H:+TraceClassInitialization -H:+PrintClassInitialization

run-native: helloworld libHelloWorld.dylib
	LD_LIBRARY_PATH=./ ./helloworld
