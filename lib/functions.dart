import firebase_admin
from firebase_admin import credentials, db, firestore
import datetime

# Initialize the Firebase Admin SDK
cred = credentials.Certificate("homeiot-6640c-firebase-adminsdk-holbh-cc427acd59.json")  # Add the path to your Firebase service account key here
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://homeiot-6640c-default-rtdb.firebaseio.com/'
})

def fetch_data_to_firebase():
    try:
        # Get a reference to the Realtime Database
        ref = db.reference('/')
        
        # Fetch data from the Realtime Database
        snapshot = ref.get()

        if snapshot:
            current_load = snapshot.get('currentLoad', None)
            current_solar_generation = snapshot.get('currentSolarGeneration', None)

            if current_load is not None and current_solar_generation is not None:
                # Prepare the sensor data to be sent to Firestore
                sensor_data = {
                    'currentLoad': current_load,
                    'currentSolarGeneration': current_solar_generation,
                    'timestamp': firestore.SERVER_TIMESTAMP  # Use Firestore's server timestamp
                }

                # Add data to Firestore
                firestore.client().collection('sensorData').add(sensor_data)
                print("Data successfully added to Firestore")
            else:
                print("Some data fields are missing in the Realtime Database.")
        else:
            print("No data available in Realtime Database")

    except Exception as e:
        print(f"Error fetching data: {e}")

# Run the function
fetch_data_to_firebase()
