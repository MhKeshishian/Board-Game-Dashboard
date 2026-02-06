import { NextResponse } from "next/server";
import {Client} from "pg";
import fs from "fs";
import path from "path";

export async function GET() {

    //Print env variables to verify
    console.log("DB_URL:", process.env.DB_URL);
    console.log("USERNAME:", process.env.DB_USERNAME);
    console.log("PW:", process.env.PW);
    console.log("DB_NAME:", process.env.DB_NAME);
    console.log("DB_PORT:", process.env.DB_PORT);
    console.log("CERT_PATH:", process.env.CERT_PATH);

    var conn = new Client(
        {
            host:process.env.DB_URL, 
            user:process.env.DB_USERNAME, 
            password:process.env.PW, 
            database:process.env.DB_NAME, 
            port:process.env.DB_PORT, 
            ssl:
                {
                    ca: fs.readFileSync(process.env.CERT_PATH).toString(),
                    rejectUnauthorized: true
                }
        });
    
    try{
            
        console.log("Connecting to database...");
        await conn.connect();
        const res = await conn.query('SELECT * FROM test_table;');
        await conn.end();
        return NextResponse.json({data: res.rows});
    
    }
    catch(err){
        console.error("Connection error", err.stack);
        return NextResponse.json({error: "Database connection failed"});
    }


}