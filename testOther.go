package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"os"
	"sync"

	_ "github.com/go-sql-driver/mysql"

	"github.com/joho/godotenv"
)

func testOther() {

	list1 := []int{1, 2, 3, 4, 5}
	list2 := []int{2, 6, 7}

	// num1 := 8
	// num2 := 5

	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatal(".env file could not be loaded")
	}

	username := os.Getenv("USER")
	pass := os.Getenv("PASSWORD")
	dbName := "test"

	// Setting up the connection to the "workshop" database
	dbURL := username + ":" + pass + "@tcp(localhost:3306)/" + dbName

	// Open a database connection
	db, err := sql.Open("mysql", dbURL)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Prepare the call book1 statement for executing later
	stmt, err := db.Prepare("CALL checkGreater(?, ?)")
	if err != nil {
		panic(err)
	}

	var wg sync.WaitGroup

	for i := 0; i < 5; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			r1 := rand.Intn(len(list1))
			r2 := rand.Intn(len(list2))

			num1 := list1[r1]
			num2 := list1[r2]

			var retStatus int
			err2 := stmt.QueryRow(num1, num2).Scan(&retStatus)
			if err != nil {
				fmt.Println(err2)
			}

			fmt.Printf("When n1: %d, n2: %d, The Return status: %d\n", num1, num2, retStatus)
		}()

	}

	wg.Wait()
	fmt.Println("End of the function")

}
