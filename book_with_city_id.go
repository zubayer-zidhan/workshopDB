package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"os"
	"sync"

	"time"

	_ "github.com/go-sql-driver/mysql"

	"github.com/joho/godotenv"
)

func book_with_city_id() {

	cid := 3
	bdate := "2023-04-19"

	// Return 3 by default, denotes failure
	var retStatus int

	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatal(".env file could not be loaded")
	}

	username := os.Getenv("USER")
	pass := os.Getenv("PASSWORD")
	dbName := os.Getenv("DBNAME")

	// Setting up the connection to the "workshop" database
	dbURL := username + ":" + pass + "@tcp(localhost:3306)/" + dbName

	// Open a database connection
	db, err := sql.Open("mysql", dbURL)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Prepare the call book1 statement for executing later
	stmt, err := db.Prepare("CALL book_with_city_id(?, ?, ?)")
	if err != nil {
		panic(err)
	}

	startTime := time.Now()
	fmt.Println(startTime)

	userIDs := []int{1, 2, 3, 4, 5, 6, 7} // 7 users available in db

	var wg sync.WaitGroup

	// Launching multiple goroutines
	// Loop runs 20 times
	for i := 0; i < 25; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			// Picking a random workshop, user, and booking date to use
			r1 := rand.Intn(len(userIDs))
			uid := userIDs[r1]

			// Calling the stored procedure
			// err := stmt.QueryRow(cid, uid, bdate).Scan(&retStatus)
			_, err := stmt.Exec(cid, uid, bdate)
			if err != nil {
				fmt.Println(err)
			}

			fmt.Printf("Booking completed for city %d, user %d, and date %s, return status %d\n", cid, uid, bdate, retStatus)
			// time.Sleep(time.Millisecond * 500)
		}()
	}

	// time.Sleep(time.Second * 5)

	// Waiting for all goroutines to complete
	wg.Wait()

	endTime := time.Since(startTime)
	fmt.Println(endTime)

	fmt.Println("All bookings completed")
}
