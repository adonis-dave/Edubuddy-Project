function downloadTopic(topic) {
    const userId = localStorage.getItem('userId');
    if (!userId) {
        alert('Please log in to download topics.');
        return;
    }
    fetch(`${API_BASE_URL}/topics/${topic}?userId=${userId}`)
        .then(response => response.json())
        .then(data => {
            if (data.content) {
                document.getElementById('topicModalLabel').textContent = topic;
                document.getElementById('topicContent').innerHTML = data.content;
                const modal = new bootstrap.Modal(document.getElementById('topicModal'));
                modal.show();
                // Save for offline access (optional)
                localStorage.setItem(`topic_${topic}`, data.content);
            } else {
                alert('Topic not found.');
            }
        })
        .catch(error => console.error('Error fetching topic:', error));
}