"use client";

import './HeroSection.css';

export default function HeroSection() {
    return(
        <section className='hero-section'>
            <div className='hero-container'>
                <div className='hero-left'>
                    <h1>StratPad</h1>
                    <p>The boardgame dashboard builder</p>
                    <button>Try it out</button>
                </div>
            </div>
        </section>
    );
}