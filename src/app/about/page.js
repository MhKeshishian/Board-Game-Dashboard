'use client'
import Image from "next/image";


export default function AboutPage() {
  return (
  <div>
    <h1>About us</h1>
  <Image
    src="/images/about-image.jpeg"
    alt="You know what you did"
    width={600}
    height={400}
  />
  </div>
)
}
