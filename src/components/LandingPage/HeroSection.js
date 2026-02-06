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
                <div class="hero-right">
                    <div class="notebook-stack">
                        <div class="notebook-page page-1"></div>
                        <div class="notebook-page page-2"></div>
                        <div class="notebook-page page-3"></div>
                    </div>
                </div>
            </div>
        </section>
    );
}