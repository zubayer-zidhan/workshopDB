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

// Book using workshopID: takes in the sql statement, workshop id, user id, and booking date
func useWorkshopID(stmt *sql.Stmt, wid int, uid int, bdate string) {
	var retStatus int
	err2 := stmt.QueryRow(wid, uid, bdate).Scan(&retStatus)
	if err2 != nil {
		fmt.Println(err2)
	}

	if retStatus == 10 {
		fmt.Printf("Booked successfully for workshop %d, user %d, on %s\n", wid, uid, bdate)
	} else if retStatus == 20 {
		fmt.Printf("Booking unsuccessful for workshop %d, user %d, on %s. All available slots have already been booked for the given city.\n", wid, uid, bdate)
	} else {
		fmt.Println("Booking failed.")
	}
}

// Book using cityID: takes in the sql statement, city id, user id, and booking date
func useCityID(stmt *sql.Stmt, cid int, uid int, bdate string) {
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
}

func book() {

	// Enter hardcoded values here
	tomorrow := time.Now().AddDate(0, 0, 1)
	bdate := tomorrow.Format("2006-01-02")

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

	// Prepare the call book_with_workshop_id stored procedure in a statement for executing later
	stmt1, err := db.Prepare("CALL book_with_workshop_id(?, ?, ?)")
	if err != nil {
		panic(err)
	}

	// Prepare the call book_with_city_id stored procedure in a statement for executing later
	stmt2, err := db.Prepare("CALL book_with_city_id(?, ?, ?)")
	if err != nil {
		panic(err)
	}

	startTime := time.Now()
	fmt.Println(startTime)

	// Data available in the database tables
	userIDs := []int{1, 2, 3, 4, 5, 6, 7}               // 7 users available in db
	workshopIDs := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10} // 10 workshops available in db
	cityIDs := []int{1, 2, 3}                           // 3 cities available in db
	randomNumbers := []int{1, 2}                        // 2 options, either book with cityID, or workshopID

	// Lengths of the above arrays
	len_userIDs := len(userIDs)
	len_workshopIDs := len(workshopIDs)
	len_cityIDs := len(cityIDs)
	len_randomNumbers := len(randomNumbers)

	var wg sync.WaitGroup

	// Launching multiple goroutines
	// Loop runs x times
	for i := 0; i < 100; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			r1 := rand.Intn(len_userIDs)
			uid := userIDs[r1]

			r2 := rand.Intn(len_randomNumbers)
			randomNumber := randomNumbers[r2]

			if randomNumber == 1 {
				// Book with workshop id
				r3 := rand.Intn(len_workshopIDs)
				wid := workshopIDs[r3]

				// Call the useWorkshopID function
				useWorkshopID(stmt1, wid, uid, bdate)

			} else {
				// Book with city id
				r3 := rand.Intn(len_cityIDs)
				cid := cityIDs[r3]

				// Call the useCityID function
				useCityID(stmt2, cid, uid, bdate)
			}

		}()
	}

	// Waiting for all goroutines to complete
	wg.Wait()

	endTime := time.Since(startTime)
	fmt.Println(endTime)

	fmt.Println("All operations completed")
}
