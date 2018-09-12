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
	dir  string
	path string
	drop bool
}

func main() {
	opts := initOpts()
	m, err := migrate.New(fileDSN(opts.path), dbDSN())
	if err != nil {
		fmt.Println("Failed to begin migration: ", err)
	}
	if opts.drop {
		err = m.Drop()
	} else {
		switch opts.dir {
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

func dbDSN() string {
	// should get info from environment
	return "postgres://postgres@localhost:5432/postgres?sslmode=disable"
}

func initOpts() opts {
	var drop bool
	if len(os.Args) > 1 {
		drop = os.Args[1] == "drop"
	}
	dir := flag.String("dir", "up", "up | down (defaults to up)")
	path := flag.String("path", "", "path to migrations directory")
	flag.Parse()
	return opts{
		dir:  *dir,
		path: *path,
		drop: drop,
	}
}
