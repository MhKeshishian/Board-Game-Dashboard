"use client";

import './FeatureCards.css';

export default function FeatureCards() {
  return (
    <div className='features-wrapper'>
        <section>
        <div className="card">
            <div className="card-image">
                {/* Image will go here */}
            </div>
            <h3>Build Your Stuff</h3>
            <p>Create custom dashboards with tables, dice rollers, and more for your tabletop games</p>
            <button>Start Building</button>
        </div>

        <div className="card">
            <div className="card-image">
                {/* Image will go here */}
            </div>
            <h3>Share Your Stuff</h3>
            <p>Export and share your custom dashboards with your gaming group or the community</p>
            <button>Share a Dashboard</button>
        </div>

        <div className="card">
            <div className="card-image">
                {/* Image will go here */}
            </div>
            <h3>Play More Games!</h3>
            <p>Spend less time on bookkeeping and more time enjoying your favourite tabletop games</p>
            <button>See How It Works</button>
        </div>
        </section>
    </div>
  );
}