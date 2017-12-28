html:
	bash md2web.sh

public: html
	rsync -av HTML/* root@207.246.93.246:/usr/share/nginx/html/

clean:
	rm -rvf HTML/
