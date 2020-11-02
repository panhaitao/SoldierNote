all: json
	./build_all.sh
json: clean_json
	./build_json.sh
clean: clean_json
	find Archive/ -type f | xargs  rm -f
clean_json:
	rm -rvf build/*.json
	
