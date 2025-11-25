import { useState, useEffect } from 'react'
import Header from './components/Header'
import Hero from './components/Hero'
import About from './components/About'
import Skills from './components/Skills'
import Projects from './components/Projects'
import Contacts from './components/Contacts'
import Footer from './components/Footer'
import './App.css'

function App() {
  const [about, setAbout] = useState(null)
  const [skills, setSkills] = useState(null)
  const [projects, setProjects] = useState(null)
  const [contacts, setContacts] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '')
      const buildUrl = (path) => `${apiBaseUrl}${path}`

      try {
        const [aboutRes, skillsRes, projectsRes, contactsRes] = await Promise.all([
          fetch(buildUrl('/api/about')),
          fetch(buildUrl('/api/skills')),
          fetch(buildUrl('/api/projects')),
          fetch(buildUrl('/api/contacts'))
        ])

        setAbout(await aboutRes.json())
        setSkills(await skillsRes.json())
        setProjects(await projectsRes.json())
        setContacts(await contactsRes.json())
      } catch (error) {
        console.error('Error fetching data:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="loading">
        <div className="spinner"></div>
        <p>Загрузка...</p>
      </div>
    )
  }

  return (
    <div className="App">
      <Header />
      <main>
        <Hero about={about} />
        <About about={about} />
        <Skills skills={skills} />
        <Projects projects={projects} />
        <Contacts contacts={contacts} />
      </main>
      <Footer />
    </div>
  )
}

export default App

