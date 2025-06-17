# 🧾 Metadata Ownership

> Use the table below to explore metadata ownership in the US CRM Salesforce Org.
<table id="owners-table" class="display" style="width:100%">
        <thead>
          <tr>
            <th>Type</th>
            <th>Name</th>
            <th>Owner</th>
            <th>Path</th>
          </tr>
        </thead>
        <tbody></tbody>
    </table>
      
    <script>
      fetch('OWNERS.json')
        .then(res => res.json())
        .then(data => {
          const tbody = document.querySelector('#owners-table tbody');
          data.forEach(item => {
            const row = document.createElement('tr');
            row.innerHTML = `
              <td>${item.metadata_type}</td>
              <td>${item.metadata_name}</td>
              <td>${item.owner}</td>
              <td>${item.path}</td>
            `;
            tbody.appendChild(row);
          });
          $('#owners-table').DataTable(); // Activate DataTable
        })
        .catch(err => console.error('Failed to fetch data:', err));
    </script>