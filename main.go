package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/golang-migrate/migrate"
	_ "github.com/golang-migrate/migrate/database/postgres"
	_ "github.com/golang-migrate/migrate/source/file"
)

type opts struct {
	kind   string
	path   string
	drop   bool
	dbhost string
}

func main() {
	opts := initOpts()
	m, err := migrate.New(fileDSN(opts.path), dbDSN(opts.dbhost))
	if err != nil {
		fmt.Println("Failed to begin migration: ", err)
	}
	if opts.drop {
		err = m.Drop()
	} else {
		switch opts.kind {
		case "up":
			err = m.Up()
		case "down":
			err = m.Down()
		}
	}
	if err != nil {
		fmt.Println("FAILED: ", err)
	} else {
		fmt.Println("SUCCESS!")
	}
}

func fileDSN(path string) string {
	return "file://" + path
}

func dbDSN(host string) string {
	// pass host from env instead of hardcoding it
	// docker network inspect migration-network
	return "postgres://postgres@" + host + "/postgres?sslmode=disable"
}

func initOpts() opts {
	var drop bool
	if len(os.Args) > 1 {
		drop = os.Args[1] == "drop"
	}
	dbhost := flag.String("dbhost", "", "ip address or hostname of db")
	kind := flag.String("kind", "up", "up | down (defaults to up)")
	path := flag.String("path", "", "path to migrations directory")
	flag.Parse()
	return opts{
		kind:   *kind,
		path:   *path,
		drop:   drop,
		dbhost: *dbhost,
	}
}
