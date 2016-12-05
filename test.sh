# Create test structure
echo "Setting up test structure"

curl -X DELETE "http://localhost:8080/fcrepo/rest/test_root" --basic -u fedoraAdmin:secret3 -o /dev/null 2> /dev/null
curl -X DELETE "http://localhost:8080/fcrepo/rest/test_root/fcr:tombstone" --basic -u fedoraAdmin:secret3 2> /dev/null
curl -X PUT "http://localhost:8080/fcrepo/rest/test_root" --basic -u fedoraAdmin:secret3; echo

# Create the base acl
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/acl.ttl" "http://localhost:8080/fcrepo/rest/test_root/acl1" --basic -u fedoraAdmin:secret3; echo

# Create the top container where acls will be assigned
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/allow_test.ttl" "http://localhost:8080/fcrepo/rest/test_root/allow_test_indir" --basic -u fedoraAdmin:secret3; echo

# Create the child
curl -X PUT "http://localhost:8080/fcrepo/rest/test_root/child" --basic -u fedoraAdmin:secret3; echo

# Create the indirect membership container for the test container
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/indirect.ttl" "http://localhost:8080/fcrepo/rest/test_root/allow_test_indir/members" --basic -u fedoraAdmin:secret3; echo

# Proxy to the child
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/child_proxy.ttl" "http://localhost:8080/fcrepo/rest/test_root/allow_test_indir/members/child_proxy" --basic -u fedoraAdmin:secret3; echo

# Create an object outside of the test container which should not grant perms
curl -X PUT "http://localhost:8080/fcrepo/rest/test_root/no_acl_cont" --basic -u fedoraAdmin:secret3; echo

# Create basic container tree with testuser perms
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/allow_test.ttl" "http://localhost:8080/fcrepo/rest/test_root/allow_test_basic" --basic -u fedoraAdmin:secret3; echo

# Create basic container child
curl -X PUT "http://localhost:8080/fcrepo/rest/test_root/allow_test_basic/basic_child" --basic -u fedoraAdmin:secret3; echo

# Create the authorization acl which grants test user rights to allow_test_indir and its children
curl -X PUT -H "Content-type: text/turtle" --data-binary "@/Users/bbpennel/Desktop/webac_test/authz_permit_testuser.ttl" "http://localhost:8080/fcrepo/rest/test_root/acl1/authz_testuser" --basic -u fedoraAdmin:secret3; echo

# Test structure
echo
echo "Evaluating results"

echo "Checking that testuser can access allow_test_indir"
[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fcrepo/rest/test_root/allow_test_indir --basic -u testuser:password1) == "200" ] && echo "passed" || echo "failed"

echo "Checking that testuser can access child via inheritance"
[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fcrepo/rest/test_root/child --basic -u testuser:password1) == "200" ] && echo "passed" || echo "failed"

echo "Checking that testuser does not have access to no_acl_cont"
[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fcrepo/rest/test_root/no_acl_cont --basic -u testuser:password1) == "403" ] && echo "passed" || echo "failed"

echo "Checking that testuser can access the basic container"
[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fcrepo/rest/test_root/allow_test_basic --basic -u testuser:password1) == "200" ] && echo "passed" || echo "failed"

echo "Checking that testuser can access the basic containers child via inheritance"
[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fcrepo/rest/test_root/allow_test_basic/basic_child --basic -u testuser:password1) == "200" ] && echo "passed" || echo "failed"