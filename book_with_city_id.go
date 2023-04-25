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
			// Selecting the output of the stored procedure into "retStatus"
			var retStatus int
			err2 := stmt.QueryRow(cid, uid, bdate).Scan(&retStatus)
			if err2 != nil {
				fmt.Println(err2)
			}

			if retStatus == 10 {
				fmt.Printf("Booked successfully for city %d, user %d, on %s\n", cid, uid, bdate)
			} else if retStatus == 20 {
				fmt.Printf("Booking unsuccessful for city %d, user %d, on %s. All available slots have already been booked for the given city.\n", cid, uid, bdate)
			} else {
				fmt.Println("Booking failed.")
			}

		}()
	}

	// Waiting for all goroutines to complete
	wg.Wait()

	endTime := time.Since(startTime)
	fmt.Println(endTime)

	fmt.Println("All bookings completed")
}
