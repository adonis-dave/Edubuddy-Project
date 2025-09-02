CREATE DATABASE edubuddy;

USE edubuddy;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    grade VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT,
    name VARCHAR(255) NOT NULL,
    content TEXT,
    file_path VARCHAR(255),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quizzes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT,
    title VARCHAR(255) NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quiz_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT,
    question TEXT NOT NULL,
    options JSON NOT NULL,
    correct_answer VARCHAR(255) NOT NULL,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

CREATE TABLE user_downloads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    topic_id INT,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id)
);

CREATE TABLE user_quiz_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    quiz_title VARCHAR(255),
    score INT,
    total_questions INT,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Sample Data Insertion
INSERT INTO subjects (name) VALUES ('Biology'), ('Geography');

INSERT INTO topics (subject_id, name, content) 
VALUES (1, 'Genetics', '<h4>1. What is Genetics?</h4><p>Genetics is the study of heredity and variation in living organisms. It explains how traits are passed from parents to offspring, why we look similar to our family members, why some diseases run in families, and how living things inherit characteristics like eye color, height, or blood type.</p><p><strong>Key terms:</strong></p><ul><li><strong>Gene:</strong> A segment of DNA that codes for a trait.</li><li><strong>Allele:</strong> Different forms of a gene (e.g., blue or brown eye color).</li><li><strong>Genome:</strong> The complete set of DNA in an organism.</li></ul><h4>2. DNA and Chromosomes</h4><p><strong>DNA (Deoxyribonucleic acid):</strong> The molecule that carries genetic information.</p><p><strong>Chromosomes:</strong> A structure made of DNA and protein that contains many genes.</p><p>Humans have 23 pairs of chromosomes, including 1 pair of sex chromosomes (X and Y).</p><h4>3. Mendelian Genetics</h4><p>Gregor Mendel discovered how traits are inherited using pea plants.</p><p><strong>Key concepts:</strong></p><ul><li><strong>Dominant allele:</strong> Masks the effect of another allele (represented as uppercase, e.g., T).</li><li><strong>Recessive allele:</strong> Only shows when two copies are present (represented as lowercase, e.g., t).</li><li><strong>Homozygous:</strong> Two identical alleles for a trait (TT or tt).</li><li><strong>Heterozygous:</strong> Two different alleles for a trait (Tt).</li></ul><p><strong>Example:</strong> If T = Tall and t = Short, then:</p><ul><li>TT or Tt = Tall</li><li>tt = Short</li></ul><h4>4. Punnett Squares</h4><p>A Punnett Square is a tool used to predict the probability of offspring inheriting certain traits.</p><p><strong>Example:</strong> Parent alleles: Aa × Aa</p><table class="table table-bordered"><tr><th></th><th>A</th><th>a</th></tr><tr><th>A</th><td>AA</td><td>Aa</td></tr><tr><th>a</th><td>Aa</td><td>aa</td></tr></table><p><strong>Result:</strong></p><ul><li>25% AA (Homozygous dominant)</li><li>50% Aa (Heterozygous)</li><li>25% aa (Homozygous recessive)</li></ul><h4>5. Types of Inheritance</h4><ul><li><strong>Dominant-Recessive:</strong> One allele dominates the other (e.g., eye color).</li><li><strong>Co-dominance:</strong> Both alleles are expressed (e.g., red + white flowers = red + white spotted flowers).</li><li><strong>Incomplete Dominance:</strong> The heterozygous phenotype is a blend (e.g., red + white flowers = pink flowers).</li><li><strong>Sex-linked traits:</strong> Genes found on sex chromosomes, often X-linked (e.g., color blindness).</li></ul><h4>6. Genetics Vocabulary Students Must Know</h4><p>Trait, gene, allele, genotype, phenotype, homozygous, heterozygous, dominant, recessive, Punnett square, chromosomes, DNA, co-dominance, incomplete dominance, sex-linked.</p>');

-- Insert more topics as needed, e.g., RainFormation

INSERT INTO quizzes (subject_id, title) VALUES (1, 'Genetics Quiz');

INSERT INTO quiz_questions (quiz_id, question, options, correct_answer)
VALUES (1, 'Which of the following is a recessive allele?', '["A", "a", "AA", "Aa"]', 'a'),
       (1, 'Homozygous means having', '["Two identical alleles", "Two different alleles", "Only dominant alleles", "Only recessive alleles"]', 'Two identical alleles'),
       (1, 'The complete set of DNA in an organism is called', '["Gene", "Chromosome", "Genome", "Allele"]', 'Genome'),
       (1, 'If a heterozygous tall pea plant (Tt) is crossed with a short pea plant (tt), what is the probability of the offspring being tall?', '["25%", "50%", "75%", "100%"]', '50%'),
       (1, 'Which statement correctly describes co-dominance and incomplete dominance?', '["Co-dominance: alleles blend; Incomplete dominance: both alleles visible", "Co-dominance: both alleles visible; Incomplete dominance: alleles blend", "Co-dominance: recessive allele hides; Incomplete dominance: dominant allele hides", "Co-dominance: only one allele expressed; Incomplete dominance: only one allele expressed"]', 'Co-dominance: both alleles visible; Incomplete dominance: alleles blend');

-- Insert more quizzes as needed