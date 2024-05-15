from flask import Flask, request, render_template, flash, redirect, url_for
import cx_Oracle

app = Flask(__name__)
app.secret_key = 'your_very_secret_key'  # Change this to a random secret key

@app.route('/', methods=['GET', 'POST'])
def add_user():
    if request.method == 'POST':
        try:
            # Connect to the database
            dsnStr = cx_Oracle.makedsn("199.212.26.208", "1521", sid="SQLD")
            conn = cx_Oracle.connect(user="COMP214_W24_zo_26", password="password", dsn=dsnStr)
            
            # Insert form data into the database
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO ZZ_patients (PATIENT_ID, NAME, DOB, GENDER, ADDRESS, PHONE_NUMBER, INSURANCE_INFO, EMAIL)
                VALUES (:1, :2, TO_DATE(:your_input_date, 'YYYY-MM-DD'), :4, :5, :6, :7, :8)
            """, (
                request.form['patientID'], 
                request.form['name'], 
                request.form['dob'], 
                request.form['gender'], 
                request.form['address'], 
                request.form['phone'], 
                request.form['insurance'], 
                request.form['email']
            ))
            conn.commit()
            cur.close()
            conn.close()

            # Flash success message
            flash(f"Patient registration successful for {request.form['name']} (ID: {request.form['patientID']})!", 'success')
        except cx_Oracle.Error as e:
            flash(f'Error: {str(e)}', 'danger')

        return redirect(url_for('add_user'))

    # GET request: just render the template
    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
