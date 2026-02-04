'use client'
import Link from 'next/link'
import './Navbar.css'

export default function Navbar() {
    return (
        <nav className='navbar'>
            <div className='navbar-brand'>
                <Link href="/">StratPad</Link>
            </div>
            <div className='navbar-links'>
                <Link href="/stratlab">StratLab</Link>
                <Link href="/stratlibrary">StratLibrary</Link>
                <Link href="/about">About</Link>
                <Link href="/login">Login</Link>
                <Link href="/signup">Sign Up</Link>
            </div>
        </nav>
    )
}