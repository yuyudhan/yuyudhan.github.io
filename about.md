---
layout: default
title: About
permalink: /about/
---

<div class="container">
    <div class="page-content" style="max-width: 800px; margin: 0 auto;">
        <!-- Header -->
        <header class="page-header text-center mb-12">
            <h1>About Me</h1>
            <p class="text-light">Get to know the person behind the code</p>
        </header>

        <!-- Main Content -->
        <div class="about-content">
            <div class="intro-section mb-12">
                <h2>Hi, I'm Ankur Pandey! 👋</h2>
                <p>
                    Welcome to my corner of the internet! I'm a passionate developer, tech enthusiast, and lifelong learner
                    who loves exploring the endless possibilities that technology offers. This blog is where I share my journey,
                    insights, and discoveries in the world of software development.
                </p>
            </div>

            <div class="section mb-12">
                <h2>My Journey</h2>
                <p>
                    My adventure in technology started with curiosity and has evolved into a deep passion for creating
                    meaningful solutions through code. I believe in the power of technology to solve real-world problems
                    and make people's lives better.
                </p>
                <p>
                    Throughout my journey, I've had the opportunity to work with various technologies, frameworks, and
                    programming languages. Each project has taught me something new and reinforced my belief that
                    continuous learning is the key to growth in this field.
                </p>
            </div>

            <div class="section mb-12">
                <h2>What I Do</h2>
                <p>
                    I enjoy working across the full stack, from designing user interfaces to architecting backend systems.
                    My interests span across:
                </p>
                <ul>
                    <li><strong>Web Development:</strong> Creating responsive, accessible, and performant web applications</li>
                    <li><strong>Backend Systems:</strong> Building scalable and reliable server-side applications</li>
                    <li><strong>Database Design:</strong> Optimizing data storage and retrieval for better performance</li>
                    <li><strong>DevOps:</strong> Streamlining deployment processes and maintaining robust infrastructure</li>
                    <li><strong>Open Source:</strong> Contributing to the community and learning from others</li>
                </ul>
            </div>

            <div class="section mb-12">
                <h2>Beyond Code</h2>
                <p>
                    When I'm not coding, you might find me:
                </p>
                <ul>
                    <li>Reading about emerging technologies and industry trends</li>
                    <li>Experimenting with new tools and frameworks</li>
                    <li>Contributing to open source projects</li>
                    <li>Learning from the amazing developer community online</li>
                    <li>Exploring creative projects that combine technology with other interests</li>
                </ul>
            </div>

            <div class="section mb-12">
                <h2>Why I Blog</h2>
                <p>
                    I started this blog to document my learning journey and share knowledge with the community.
                    I believe that teaching others is one of the best ways to solidify your own understanding,
                    and I hope my experiences can help others on their own paths.
                </p>
                <p>
                    Whether you're a beginner just starting out or an experienced developer looking for new perspectives,
                    I hope you'll find something valuable here. The tech community has given me so much, and this is
                    my way of giving back.
                </p>
            </div>

            <div class="section mb-12">
                <h2>Let's Connect!</h2>
                <p>
                    I'd love to connect with fellow developers, tech enthusiasts, and anyone interested in technology.
                    Feel free to reach out if you want to:
                </p>
                <ul>
                    <li>Discuss a blog post or share your thoughts</li>
                    <li>Collaborate on interesting projects</li>
                    <li>Ask questions or seek advice</li>
                    <li>Just say hello!</li>
                </ul>

                <div class="connect-links" style="display: flex; gap: var(--space-4); justify-content: center; margin-top: var(--space-8); flex-wrap: wrap;">
                    <a href="https://github.com/yuyudhan" target="_blank" rel="noopener" class="btn">
                        <i class="fab fa-github"></i> GitHub
                    </a>
                    <a href="https://twitter.com/yuyudhan" target="_blank" rel="noopener" class="btn">
                        <i class="fab fa-twitter"></i> Twitter
                    </a>
                    <a href="/contact" class="btn">
                        <i class="fas fa-envelope"></i> Contact Me
                    </a>
                </div>
            </div>

            <div class="section">
                <h2>Fun Facts</h2>
                <ul>
                    <li>🚀 I'm always excited about learning new technologies</li>
                    <li>💡 I believe the best solutions often come from the simplest approaches</li>
                    <li>🌱 I'm a strong advocate for continuous learning and growth</li>
                    <li>🤝 I love collaborating with others and learning from different perspectives</li>
                    <li>📚 I enjoy reading both technical books and fiction in my spare time</li>
                </ul>
            </div>
        </div>
    </div>

</div>

<style>
/* About page specific styles */
.page-header {
    padding: var(--space-12) 0;
}

.page-header h1 {
    font-size: var(--font-size-4xl);
    background: var(--gradient-primary);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.about-content {
    line-height: 1.8;
}

.about-content h2 {
    color: var(--primary-color);
    margin-bottom: var(--space-6);
    font-size: var(--font-size-2xl);
}

.about-content p {
    margin-bottom: var(--space-4);
    color: var(--text-color);
}

.about-content ul {
    margin-bottom: var(--space-6);
    padding-left: var(--space-6);
}

.about-content li {
    margin-bottom: var(--space-2);
    color: var(--text-color);
}

.about-content li strong {
    color: var(--primary-color);
}

.section {
    padding-bottom: var(--space-8);
    border-bottom: 1px solid var(--border-color);
}

.section:last-child {
    border-bottom: none;
}

.connect-links .btn {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    min-width: 120px;
    justify-content: center;
}

@media (max-width: 768px) {
    .connect-links {
        flex-direction: column;
        align-items: center;
    }

    .connect-links .btn {
        width: 200px;
    }
}
</style>

